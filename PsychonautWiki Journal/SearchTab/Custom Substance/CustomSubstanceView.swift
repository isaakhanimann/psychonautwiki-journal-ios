import SwiftUI

struct CustomSubstanceView: View {

    @ObservedObject var customSubstance: CustomSubstance
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingConfirmation = false

    var body: some View {
        List {
            Section("Units") {
                Text(customSubstance.unitsUnwrapped)
            }
            Section("Description") {
                Text(customSubstance.explanationUnwrapped)
            }
            Section {
                HStack {
                    Spacer()
                    Button {
                        isShowingConfirmation.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this substance?",
            isPresented: $isShowingConfirmation
        ) {
            Button("Delete Substance", role: .destructive) {
                dismiss()
                PersistenceController.shared.viewContext.delete(customSubstance)
                PersistenceController.shared.saveViewContext()
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle(customSubstance.nameUnwrapped)
    }
}
