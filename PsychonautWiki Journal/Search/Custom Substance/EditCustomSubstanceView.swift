import SwiftUI

struct EditCustomSubstanceView: View {

    @ObservedObject var customSubstance: CustomSubstance
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingConfirmation = false
    @State private var units = ""
    @State private var description = ""

    var body: some View {
        List {
            Section("Units") {
                TextField("Units", text: $units)
            }
            Section("Description") {
                TextField("Description", text: $description)
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
        .optionalScrollDismissesKeyboard()
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
        .onAppear {
            units = customSubstance.unitsUnwrapped
            description = customSubstance.explanationUnwrapped
        }
        .toolbar {
            ToolbarItem {
                Button("Done") {
                    if !units.isEmpty {
                        customSubstance.units = units
                        customSubstance.explanation = description
                        PersistenceController.shared.saveViewContext()
                    }
                    dismiss()
                }
            }
        }
        .navigationTitle(customSubstance.nameUnwrapped)
    }
}
