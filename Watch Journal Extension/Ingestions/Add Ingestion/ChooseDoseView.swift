import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dismiss: () -> Void
    let experience: Experience

    @State private var selectedDose: Double?
    @State private var isKeyboardShowing = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                DosePicker(
                    doseInfo: substance.getDose(for: administrationRoute),
                    doseMaybe: $selectedDose
                )
            }
            if let doseDouble = selectedDose, doseDouble != 0 {
                NavigationLink(
                    destination: ChooseTimeAndColor(
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
                .padding()
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
