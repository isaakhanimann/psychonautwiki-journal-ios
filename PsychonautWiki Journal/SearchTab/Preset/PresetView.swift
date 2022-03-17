import SwiftUI
import AlertToast

struct PresetView: View {

    @ObservedObject var preset: Preset
    @State private var isShowingAddIngestionSheet = false
    @State private var isShowingSuccessToast = false

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
            PresetInteractionsSection(preset: preset)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Ingest") {
                    isShowingAddIngestionSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $isShowingAddIngestionSheet) {
            let showInteractionSheet = preset.substances.contains(where: { sub in
                sub.hasAnyInteractions
            }) || !preset.dangerousInteractions.isEmpty
            || !preset.unsafeInteractions.isEmpty
            || !preset.uncertainInteractions.isEmpty
            NavigationView {
                if showInteractionSheet {
                    PresetAcknowledgeInteractionsView(
                        preset: preset,
                        dismiss: dismiss,
                        experience: nil
                    )
                } else {
                    PresetChooseDoseView(
                        preset: preset,
                        dismiss: dismiss,
                        experience: nil
                    )
                }
            }
            .accentColor(Color.blue)
        }
        .toast(isPresenting: $isShowingSuccessToast) {
            AlertToast(
                displayMode: .alert,
                type: .complete(Color.green),
                title: "Ingestion Added"
            )
        }
        .navigationTitle(preset.nameUnwrapped)
    }

    private func dismiss(result: AddResult) {
        if result == .ingestionWasAdded {
            isShowingSuccessToast.toggle()
        }
        isShowingAddIngestionSheet.toggle()
    }
}

struct PresetView_Previews: PreviewProvider {
    static var previews: some View {
        PresetView(preset: PreviewHelper.shared.preset)
    }
}
