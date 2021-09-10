import SwiftUI

struct ChooseSubstanceView: View {

    let substancesFile: SubstancesFile
    let dismiss: () -> Void
    let experience: Experience

    @State private var isKeyboardShowing = false
    @State private var searchText = ""
    @State private var recentsFiltered: [Substance]
    @State private var favoritesFiltered: [Substance]
    @State private var categoriesSearchResults: [CategorySearchResult]

    init(
        substancesFile: SubstancesFile,
        dismiss: @escaping () -> Void,
        experience: Experience
    ) {
        self.substancesFile = substancesFile
        self.dismiss = dismiss
        self.experience = experience
        self.recentsFiltered = substancesFile.getRecentlyUsedSubstancesInOrder(
            maxSubstancesToGet: 5
        )
        self.favoritesFiltered = substancesFile.favoritesSorted
        self.categoriesSearchResults = substancesFile.sortedCategoriesUnwrapped.compactMap { category in
            if category.sortedEnabledSubstancesUnwrapped.isEmpty {
                return nil
            } else {
                return CategorySearchResult(
                    categoryName: category.nameUnwrapped,
                    filteredSubstances: category.sortedEnabledSubstancesUnwrapped
                )
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                let searchBinding = Binding<String>(
                    get: {self.searchText},
                    set: {
                        self.searchText = $0
                        filterSubstances(with: $0)
                    }
                )
                TextField("Search Substances", text: searchBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .padding(.horizontal)
                List {
                    if !recentsFiltered.isEmpty {
                        Section(header: Text("Recently Used")) {
                            ForEach(recentsFiltered) { substance in
                                SubstanceRow(substance: substance, dismiss: dismiss, experience: experience)
                            }
                        }
                    }
                    if !favoritesFiltered.isEmpty {
                        Section(header: Text("Favorites")) {
                            ForEach(favoritesFiltered) { substance in
                                SubstanceRow(substance: substance, dismiss: dismiss, experience: experience)
                            }
                        }
                    }
                    ForEach(categoriesSearchResults) { categoriesSearchResult in
                        Section(header: Text(categoriesSearchResult.categoryName)) {
                            ForEach(categoriesSearchResult.filteredSubstances) { substance in
                                SubstanceRow(substance: substance, dismiss: dismiss, experience: experience)
                            }
                        }
                    }

                    if recentsFiltered.isEmpty
                        && favoritesFiltered.isEmpty
                        && categoriesSearchResults.isEmpty {
                        Text("No substances found")
                            .foregroundColor(.secondary)
                    }

                }
                .listStyle(PlainListStyle())
                .cornerRadius(10)

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

    struct CategorySearchResult: Identifiable {
        // swiftlint:disable identifier_name
        var id: String {
            categoryName
        }
        let categoryName: String
        let filteredSubstances: [Substance]
    }

    private func filterSubstances(with search: String) {
        self.recentsFiltered = substancesFile.getRecentlyUsedSubstancesInOrder(
            maxSubstancesToGet: 5
        ).filter { substance in
            substance.nameUnwrapped.hasPrefix(searchText)
        }
        self.favoritesFiltered = substancesFile.favoritesSorted.filter { substance in
            substance.nameUnwrapped.hasPrefix(searchText)
        }
        self.categoriesSearchResults = substancesFile.sortedCategoriesUnwrapped.compactMap { category in
            let filteredSubstancesInCategory = category.enabledSubstancesUnwrapped.filter(doesSearchTermInclude)
            if filteredSubstancesInCategory.isEmpty {
                return nil
            } else {
                return CategorySearchResult(
                    categoryName: category.nameUnwrapped,
                    filteredSubstances: filteredSubstancesInCategory
                )
            }
        }
    }

    private func doesSearchTermInclude(substance: Substance) -> Bool {
        if searchText.isEmpty {
            return true
        } else {
            return substance.nameUnwrapped.lowercased().contains(searchText.lowercased())
        }
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseSubstanceView(
            substancesFile: helper.substancesFile,
            dismiss: {},
            experience: helper.experiences.first!
        )
        .environmentObject(helper.experiences.first!)
    }
}
