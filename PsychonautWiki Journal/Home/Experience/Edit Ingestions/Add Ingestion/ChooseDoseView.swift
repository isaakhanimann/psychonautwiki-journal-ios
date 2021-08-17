import SwiftUI

struct ChooseDoseView: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dismiss: () -> Void

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
                        dismiss: dismiss
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
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseDoseView(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dismiss: {}
        )
    }
}
