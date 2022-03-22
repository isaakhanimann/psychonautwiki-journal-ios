import SwiftUI

struct PresetView: View {

    @ObservedObject var preset: Preset
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingConfirmation = false
    @EnvironmentObject var sheetViewModel: SheetViewModel
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        List {
            Section("Units") {
                Text(preset.unitsUnwrapped)
            }
            Section("1 \(preset.unitsUnwrapped) contains") {
                ForEach(preset.componentsUnwrapped) { com in
                    if let sub = com.substance {
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            HStack {
                                Text(com.substanceNameUnwrapped)
                                Spacer()
                                let dose = com.dosePerUnitOfPresetUnwrapped?.formatted() ?? "undefined"
                                Text("\(dose) \(com.unitsUnwrapped) \(com.administrationRoute ?? "")")
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        HStack {
                            Text(com.substanceNameUnwrapped)
                            Spacer()
                            let dose = com.dosePerUnitOfPresetUnwrapped?.formatted() ?? "undefined"
                            Text("\(dose) \(com.unitsUnwrapped) \(com.administrationRoute ?? "")")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            if isEyeOpen {
                PresetInteractionsSection(preset: preset)
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
                    sheetViewModel.sheetToShow = .addIngestionFromPreset(preset: preset)
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this Preset?",
            isPresented: $isShowingConfirmation
        ) {
            Button("Delete Preset", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                PersistenceController.shared.viewContext.delete(preset)
                PersistenceController.shared.saveViewContext()
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle(preset.nameUnwrapped)
    }
}

struct PresetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PresetView(preset: PreviewHelper.shared.preset)
        }
    }
}
