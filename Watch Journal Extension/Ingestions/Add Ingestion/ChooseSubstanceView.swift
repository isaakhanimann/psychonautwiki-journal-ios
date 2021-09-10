import SwiftUI

struct ChooseSubstanceView: View {

    let substancesFile: SubstancesFile
    let dismiss: () -> Void
    let experience: Experience

    @State private var selectedSubstance: Substance
    @State private var isNavigatedToDose = false
    @State private var isNavigatedToRoute = false
    @State private var administrationRoute: Roa.AdministrationRoute
    @State private var isKeyboardShowing = false

    init(
        substancesFile: SubstancesFile,
        dismiss: @escaping () -> Void,
        experience: Experience
    ) {
        self.substancesFile = substancesFile
        self.dismiss = dismiss
        self.experience = experience
        self._selectedSubstance = State(wrappedValue: substancesFile.newIngestionDefaultSubstance!)
        self._administrationRoute = State(
            wrappedValue: substancesFile.newIngestionDefaultSubstance!.administrationRoutesUnwrapped.first!
        )
    }

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
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    Button("Cancel", action: dismiss)
                }
            }
        }
    }

    private func moveToNextScreen(chosenSubstance: Substance) {
        self.selectedSubstance = chosenSubstance
        if selectedSubstance.administrationRoutesUnwrapped.count > 1 {
            isNavigatedToRoute.toggle()
        } else {
            navigateToDose(route: selectedSubstance.administrationRoutesUnwrapped.first!)
        }
    }

    private func navigateToDose(route: Roa.AdministrationRoute) {
        administrationRoute = route
        isNavigatedToDose.toggle()
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
