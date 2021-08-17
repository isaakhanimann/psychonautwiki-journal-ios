import SwiftUI
import CoreData

struct AddFileView: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc

    @State private var filename = ""
    @State private var isKeyboardShowing = false
    @State private var isShowingAlert = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Enter Name", text: $filename)
            }
            .alert(
                isPresented: $isShowingAlert,
                content: {
                            Alert(
                                title: Text("Name Empty"),
                                message: Text("The name must not be empty"),
                                dismissButton: .default(Text("Ok"))
                            )
                        }
            )
            .navigationTitle("Add Definitions")
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
                        Button("Add", action: addFile)
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

    private func addFile() {
        guard !filename.isEmpty else {
            self.isShowingAlert.toggle()
            return
        }

        moc.performAndWait {
            let file = SubstancesFile(context: moc)
            file.filename = filename
            file.creationDate = Date()
            do {
                try moc.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }

        presentationMode.wrappedValue.dismiss()
    }
}
