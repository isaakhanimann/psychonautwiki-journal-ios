import SwiftUI
import AlertToast

struct CustomSubstanceView: View {

    @ObservedObject var customSubstance: CustomSubstance
    @State private var isShowingAddCustomSheet = false
    @State private var isShowingSuccessToast = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingConfirmation = false

    var body: some View {
        List {
            Section("Units") {
                Text(customSubstance.unitsUnwrapped)
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    isShowingConfirmation.toggle()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .foregroundColor(.red)
            }
            ToolbarItem(placement: .navigation) {
                Button("Ingest") {
                    isShowingAddCustomSheet.toggle()
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this substance?",
            isPresented: $isShowingConfirmation
        ) {
            Button("Delete Substance", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                PersistenceController.shared.viewContext.delete(customSubstance)
                PersistenceController.shared.saveViewContext()
            }
            Button("Cancel", role: .cancel) {}
        }
        .toast(isPresenting: $isShowingSuccessToast) {
            AlertToast(
                displayMode: .alert,
                type: .complete(Color.green),
                title: "Ingestion Added"
            )
        }
        .sheet(isPresented: $isShowingAddCustomSheet) {
            NavigationView {
                AddCustomIngestionView(customSubstance: customSubstance)
            }
            .accentColor(Color.blue)
            .environmentObject(
                AddIngestionSheetContext(
                    experience: nil,
                    showSuccessToast: {
                        isShowingSuccessToast.toggle()
                    },
                    isShowingAddIngestionSheet: $isShowingAddCustomSheet
                )
            )
        }
        .navigationTitle(customSubstance.nameUnwrapped)
    }
}

struct CustomSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomSubstanceView(customSubstance: PreviewHelper.shared.customSubstance)
        }
    }
}
