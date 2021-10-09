import SwiftUI

struct ChooseSubstanceView: View {

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var storedFile: FetchedResults<SubstancesFile>

    let dismiss: () -> Void
    let experience: Experience

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                let recentSubstances = storedFile.first?.getRecentlyUsedSubstancesInOrder(
                    maxSubstancesToGet: 5
                ) ?? []
                if !recentSubstances.isEmpty {
                    Section(header: Text("Recently Used")) {
                        ForEach(recentSubstances) { substance in
                            SubstanceRow(
                                substance: substance,
                                dismiss: dismiss,
                                experience: experience
                            )
                        }
                    }
                }
                let favoritesEnabled = storedFile.first?.favoritesSorted.filter({$0.isEnabled}) ?? []
                if !favoritesEnabled.isEmpty {
                    Section(header: Text("Favorites")) {
                        ForEach(favoritesEnabled) { substance in
                            SubstanceRow(
                                substance: substance,
                                dismiss: dismiss,
                                experience: experience
                            )
                        }
                    }
                }

                ForEach(storedFile.first?.categoriesUnwrappedSorted ?? []) { category in
                    let enabledSubstances = category.sortedEnabledSubstancesUnwrapped
                    if !enabledSubstances.isEmpty {
                        Section(header: Text(category.nameUnwrapped)) {
                            ForEach(category.sortedEnabledSubstancesUnwrapped) { substance in
                                SubstanceRow(
                                    substance: substance,
                                    dismiss: dismiss,
                                    experience: experience
                                )
                            }
                        }
                    }
                }

                if isEyeOpen {
                    Section {
                        EmptyView()
                    } footer: {
                        Text(Constants.substancesDisclaimerWatch)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    Button("Cancel", action: dismiss)
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
    }
}
