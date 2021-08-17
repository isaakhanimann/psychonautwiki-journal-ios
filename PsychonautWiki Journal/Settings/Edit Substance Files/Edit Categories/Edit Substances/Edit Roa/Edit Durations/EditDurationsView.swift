import SwiftUI
import CoreData

struct EditDurationsView: View {

    @ObservedObject var durationTypes: DurationTypes

    @Environment(\.managedObjectContext) var moc

    @State private var isKeyboardShowing = false

    var body: some View {
        Form {
            EditDurationRangeSection(label: "onset", durationRange: durationTypes.onset!)
            EditDurationRangeSection(label: "comeup", durationRange: durationTypes.comeup!)
            EditDurationRangeSection(label: "peak", durationRange: durationTypes.peak!)
            EditDurationRangeSection(label: "offset", durationRange: durationTypes.offset!)
        }
        .navigationTitle("Edit Duration Info")
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
}
