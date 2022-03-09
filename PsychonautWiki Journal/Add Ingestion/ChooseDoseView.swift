import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dismiss: (AddResult) -> Void
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
            ToolbarItem(placement: .keyboard) {
                if isKeyboardShowing {
                    Button("Done", action: hideKeyboard)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss(.cancelled)
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
            dismiss: {print($0)},
            experience: helper.experiences.first!
        )
    }
}
