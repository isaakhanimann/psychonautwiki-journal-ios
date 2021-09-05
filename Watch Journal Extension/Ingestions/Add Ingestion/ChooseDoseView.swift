import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dismiss: () -> Void
    let experience: Experience

    @State private var selectedDose: Double?
    @State private var isKeyboardShowing = false

    var body: some View {
        VStack {
            DosePicker(
                doseInfo: substance.getDose(for: administrationRoute),
                doseMaybe: $selectedDose
            )
            if let doseDouble = selectedDose, doseDouble != 0 {
                NavigationLink(
                    destination: ChooseColor(
                        substance: substance,
                        administrationRoute: administrationRoute,
                        dose: doseDouble,
                        dismiss: dismiss,
                        experience: experience
                    ),
                    label: {
                        Text("Next")
                    }
                )
            }
        }
        .navigationBarTitle("Choose Dose")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                Button("Cancel", action: dismiss)
            }
        }
    }
}

struct ChooseDoseView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseDoseView(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
