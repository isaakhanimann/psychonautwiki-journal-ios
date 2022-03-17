import SwiftUI

struct PresetChooseTimeAndColorsView: View {

    let preset: Preset
    let dose: Double
    let dismiss: (AddResult) -> Void
    let experience: Experience?
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section("Choose Time") {
                    DatePicker(
                        "Time",
                        selection: $viewModel.selectedTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                }
                ForEach($viewModel.componentColorCombos) { $combo in
                    Section("\(combo.component.substanceNameUnwrapped) Color") {
                        ColorPicker(selectedColor: $combo.selectedColor)
                    }
                }
                bottomPadding
            }
            if let experienceUnwrap = experience {
                Button("Add Ingestion") {
                    viewModel.addIngestions(to: experienceUnwrap)
                    dismiss(.ingestionWasAdded)
                }
                .buttonStyle(.primary)
                .padding()
            } else {
                VStack {
                    let twoDaysAgo = Date().addingTimeInterval(-2*24*60*60)
                    if let lastExperienceUnwrap = viewModel.lastExperience,
                       lastExperienceUnwrap.dateForSorting > twoDaysAgo {
                        Button("Add to \(lastExperienceUnwrap.titleUnwrapped)") {
                            viewModel.addIngestions(to: lastExperienceUnwrap)
                            dismiss(.ingestionWasAdded)
                        }
                        .padding(.horizontal)
                    }
                    Button("Add to New Experience") {
                        viewModel.addIngestionsToNewExperience()
                        dismiss(.ingestionWasAdded)
                    }
                    .padding()
                }
                .buttonStyle(.primary)
            }
        }
        .task {
            viewModel.preset = preset
            viewModel.presetDose = dose
            if experience == nil {
                viewModel.setLastExperience()
            }
            viewModel.componentColorCombos = preset.componentsUnwrapped.map { com in
                ComponentColorCombo(component: com)
            }
        }
        .navigationBarTitle("Ingestion Time")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss(.cancelled)
                }
            }
        }
    }

    var bottomPadding: some View {
        Section(header: Text("")) {
            EmptyView()
        }
        .padding(.bottom, 50)
    }
}

struct PresetChooseTimeAndColorsView_Previews: PreviewProvider {
    static var previews: some View {
        PresetChooseTimeAndColorsView(
            preset: PreviewHelper.shared.preset,
            dose: 1,
            dismiss: { _ in },
            experience: nil
        )
    }
}
