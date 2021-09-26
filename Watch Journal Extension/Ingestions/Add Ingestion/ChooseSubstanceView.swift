import SwiftUI

struct ChooseSubstanceView: View {

    let substancesFile: SubstancesFile
    let dismiss: () -> Void
    let experience: Experience

    var body: some View {
        NavigationView {
            let recentSubstances = substancesFile.getRecentlyUsedSubstancesInOrder(
                maxSubstancesToGet: 5
            )
            List {

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
                if !substancesFile.favoritesSorted.isEmpty {
                    Section(header: Text("Favorites")) {
                        ForEach(substancesFile.favoritesSorted) { substance in
                            SubstanceRow(
                                substance: substance,
                                dismiss: dismiss,
                                experience: experience
                            )
                        }
                    }
                }

                ForEach(substancesFile.categoriesUnwrappedSorted) { category in
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

                Text(Constants.substancesDisclaimerWatch).font(.footnote)

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
            substancesFile: helper.substancesFile,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
