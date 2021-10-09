import SwiftUI

struct ChooseSubstanceView: View {

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var storedFile: FetchedResults<SubstancesFile>

    let dismiss: () -> Void
    let experience: Experience

    @State private var isKeyboardShowing = false
    @State private var searchText = ""

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Substances", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.words)
                    .padding(.horizontal)
                List {
                    let recentsFiltered = storedFile.first?
                        .getRecentlyUsedSubstancesInOrder(maxSubstancesToGet: 5)
                        .filter({ substance in
                            substance.nameUnwrapped.lowercased().hasPrefix(searchText.lowercased()) &&
                            substance.isEnabled
                        }) ?? []
                    if !recentsFiltered.isEmpty {
                        Section(header: Text("Recently Used")) {
                            ForEach(recentsFiltered) { substance in
                                SubstanceRow(substance: substance, dismiss: dismiss, experience: experience)
                            }
                        }
                    }
                    let favoritesFiltered = storedFile.first?
                        .favoritesSorted
                        .filter({ substance in
                            substance.nameUnwrapped.lowercased().hasPrefix(searchText.lowercased()) &&
                            substance.isEnabled
                        }) ?? []
                    if !favoritesFiltered.isEmpty {
                        Section(header: Text("Favorites")) {
                            ForEach(favoritesFiltered) { substance in
                                SubstanceRow(substance: substance, dismiss: dismiss, experience: experience)
                            }
                        }
                    }
                    let categories = storedFile.first?
                        .categoriesUnwrappedSorted
                        .filter({ cat in
                            cat.substancesUnwrapped.contains { substance in
                                substance.nameUnwrapped.lowercased().hasPrefix(searchText.lowercased()) &&
                                substance.isEnabled
                            }
                        }) ?? []
                    ForEach(categories) { category in
                        Section(header: Text(category.nameUnwrapped)) {
                            let filteredSubstances = category.substancesUnwrapped
                                .filter({ substance in
                                    substance.nameUnwrapped.lowercased().hasPrefix(searchText.lowercased()) &&
                                    substance.isEnabled
                                })
                            ForEach(filteredSubstances) { substance in
                                SubstanceRow(substance: substance, dismiss: dismiss, experience: experience)
                            }
                        }
                    }

                    if recentsFiltered.isEmpty
                        && favoritesFiltered.isEmpty
                        && categories.isEmpty {
                        Text("No substances found")
                            .foregroundColor(.secondary)
                    }

                    if isEyeOpen {
                        Section {
                            EmptyView()
                        } footer: {
                            Text(Constants.substancesDisclaimerIOS)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(PlainListStyle())

                Spacer().frame(maxHeight: 1) // fix SwiftUI bug, make the last element in the list show
            }
            .navigationBarTitle("Add Ingestion")
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = false
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    if isKeyboardShowing {
                        Button("Done", action: hideKeyboard)
                    } else {
                        Button("Cancel", action: dismiss)
                    }
                }
            }
        }
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseSubstanceView(
            dismiss: {},
            experience: helper.experiences.first!
        )
            .environmentObject(helper.experiences.first!)
    }
}
