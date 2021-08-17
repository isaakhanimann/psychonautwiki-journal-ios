import SwiftUI

struct AddCategoryView: View {

    @ObservedObject var file: SubstancesFile

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc

    @State private var name = ""
    @State private var isKeyboardShowing = false

    var body: some View {
        NavigationView {
            Form {
                TextField("Enter Name", text: $name)
            }
            .navigationTitle("Add Category")
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
                        Button("Add", action: addCategory)
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

    private func addCategory() {
        moc.performAndWait {
            let newCategory = Category(context: moc)
            newCategory.name = name
            newCategory.file = file
            if moc.hasChanges {
                try? moc.save()
            }
        }

        presentationMode.wrappedValue.dismiss()
    }
}
