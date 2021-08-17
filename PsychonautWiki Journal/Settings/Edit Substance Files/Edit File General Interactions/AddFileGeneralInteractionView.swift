import SwiftUI

struct AddFileGeneralInteractionView: View {

    @ObservedObject var file: SubstancesFile

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc

    @State private var name = ""
    @State private var isEnabled = false
    @State private var isKeyboardShowing = false

    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Name")
                        .foregroundColor(.secondary)
                    TextField("Enter Name", text: $name)
                }
                Section {
                    Toggle("Enabled", isOn: $isEnabled)
                }
            }
            .navigationTitle("Add General Interaction")
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    if isKeyboardShowing {
                        Button("Done", action: hideKeyboard)
                            .font(.callout)
                    } else {
                        Button("Add", action: addFileGeneralInteraction)
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
        .currentDeviceNavigationViewStyle()
    }

    private func addFileGeneralInteraction() {
        moc.performAndWait {
            let newInteraction = GeneralInteraction(context: moc)
            newInteraction.name = name
            newInteraction.isEnabled = isEnabled
            file.addToGeneralInteractions(newInteraction)

            if moc.hasChanges {
                try? moc.save()
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
}
