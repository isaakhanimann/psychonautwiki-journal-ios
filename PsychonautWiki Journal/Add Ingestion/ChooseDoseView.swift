import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dismiss: () -> Void
    let experience: Experience?

    @State private var selectedDose: Double?
    @State private var isKeyboardShowing = false

    // swiftlint:disable line_length
    static let doseDisclaimer = "Dosage information is gathered from users and resources such as clinical studies. It is not a recommendation and should be verified with other sources for accuracy."

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section(footer: Text(Self.doseDisclaimer)
                ) {
                    DosePicker(
                        roaDose: substance.getDose(for: administrationRoute),
                        doseMaybe: $selectedDose
                    )
                }
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
                            .primaryButtonText()
                    }
                )
                .padding()
            }
        }
        .navigationBarTitle("Choose Dose")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                if isKeyboardShowing {
                    Button("Done", action: hideKeyboard)
                } else {
                    Button("Cancel", action: dismiss)
                }
            }
        }
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
    }
}

struct ChooseDoseView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        ChooseDoseView(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
