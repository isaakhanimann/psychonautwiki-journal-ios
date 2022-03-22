import SwiftUI
import AlertToast

struct CustomSubstanceView: View {

    @ObservedObject var customSubstance: CustomSubstance
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingConfirmation = false
    @EnvironmentObject var sheetViewModel: SheetViewModel

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
                    sheetViewModel.sheetToShow = .addIngestionFromCustom(custom: customSubstance)
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
