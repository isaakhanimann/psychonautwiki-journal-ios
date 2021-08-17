import SwiftUI

struct ChooseSubstanceView: View {

    let substancesFile: SubstancesFile
    let dismiss: () -> Void

    @State private var selectedSubstance: Substance
    @State private var isNavigatedToDose = false
    @State private var isNavigatedToRoute = false
    @State private var administrationRoute: Roa.AdministrationRoute
    @State private var isKeyboardShowing = false

    init(substancesFile: SubstancesFile, dismiss: @escaping () -> Void) {
        self.substancesFile = substancesFile
        self.dismiss = dismiss
        self._selectedSubstance = State(wrappedValue: substancesFile.newIngestionDefaultSubstance!)
        self._administrationRoute = State(
            wrappedValue: substancesFile.newIngestionDefaultSubstance!.administrationRoutesUnwrapped.first!
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                // This is a fix for a navigation bug of SwiftUI
                // where if on the next screen one e.g. clicks on a TextField it navigates back
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
                NavigationLink(
                    destination: ChooseDoseView(
                        substance: selectedSubstance,
                        administrationRoute: administrationRoute,
                        dismiss: dismiss
                    ),
                    isActive: $isNavigatedToDose,
                    label: {
                        EmptyView()
                    }
                )
                NavigationLink(
                    destination: ChooseRouteView(substance: selectedSubstance, dismiss: dismiss),
                    isActive: $isNavigatedToRoute,
                    label: {
                        EmptyView()
                    }
                )
                SubstancePicker(
                    selectedSubstance: selectedSubstance,
                    substancesFile: substancesFile,
                    chooseSubstanceAndMoveOn: moveToNextScreen
                )
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
        ChooseSubstanceView(substancesFile: helper.substancesFile, dismiss: {})
            .environmentObject(helper.experiences.first!)
    }
}
