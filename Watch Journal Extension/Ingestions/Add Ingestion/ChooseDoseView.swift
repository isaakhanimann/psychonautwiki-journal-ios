import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dismiss: () -> Void
    let experience: Experience

    @State private var selectedDose: Double?

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                DosePicker(
                    doseInfo: substance.getDose(for: administrationRoute),
                    doseMaybe: $selectedDose
                )

                if let doseDouble = selectedDose, doseDouble != 0 {
                    NavigationLink(
                        destination: ChooseTimeView(
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
                    .buttonStyle(BorderedButtonStyle(tint: .accentColor))
                }

                Text(Constants.doseDisclaimer)
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
        let helper = PreviewHelper()
        ChooseDoseView(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
