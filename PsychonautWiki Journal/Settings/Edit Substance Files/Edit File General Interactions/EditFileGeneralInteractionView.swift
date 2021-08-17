import SwiftUI

struct EditFileGeneralInteractionView: View {

    @ObservedObject var generalInteraction: GeneralInteraction

    @Environment(\.managedObjectContext) var moc

    @State private var name: String
    @State private var isEnabled: Bool
    @State private var isKeyboardShowing = false

    init(generalInteraction: GeneralInteraction) {
        self.generalInteraction = generalInteraction
        self._name = State(wrappedValue: generalInteraction.nameUnwrapped)
        self._isEnabled = State(wrappedValue: generalInteraction.isEnabled)
    }

    var body: some View {
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
        .navigationTitle("Edit Interaction")
        .onChange(of: name) { _ in update() }
        .onChange(of: isEnabled) { _ in update() }
        .onDisappear(perform: {
            if moc.hasChanges {
                try? moc.save()
            }
        })
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
                    Button {
                        hideKeyboard()
                        if moc.hasChanges {
                            try? moc.save()
                        }
                    } label: {
                        Text("Done")
                            .font(.callout)
                    }
                }
            }
        }
    }

    func update() {
        generalInteraction.file!.objectWillChange.send()
        generalInteraction.name = name
        generalInteraction.isEnabled = isEnabled
    }
}
