import SwiftUI

struct PresetChooseTimeAndColorsView: View {

    let preset: Preset
    let dose: Double
    @EnvironmentObject var sheetContext: AddIngestionSheetContext
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
                EmptySectionForPadding()
            }
            if let experienceUnwrap = sheetContext.experience {
                Button("Add Ingestion") {
                    viewModel.addIngestions(to: experienceUnwrap)
                    sheetContext.isShowingAddIngestionSheet.toggle()
                    sheetContext.showSuccessToast()
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
                            sheetContext.isShowingAddIngestionSheet.toggle()
                            sheetContext.showSuccessToast()
                        }
                        .padding(.horizontal)
                    }
                    Button("Add to New Experience") {
                        viewModel.addIngestionsToNewExperience()
                        sheetContext.isShowingAddIngestionSheet.toggle()
                        sheetContext.showSuccessToast()
                    }
                    .padding()
                }
                .buttonStyle(.primary)
            }
        }
        .task {
            viewModel.presetDose = dose
            if sheetContext.experience == nil {
                viewModel.lastExperience = PersistenceController.shared.getLatestExperience()
            }
            viewModel.componentColorCombos = preset.componentsUnwrapped.map { com in
                ComponentColorCombo(component: com)
            }
        }
        .navigationBarTitle("Ingestion Time")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    sheetContext.isShowingAddIngestionSheet.toggle()
                }
            }
        }
    }
}

struct PresetChooseTimeAndColorsView_Previews: PreviewProvider {
    static var previews: some View {
        PresetChooseTimeAndColorsView(
            preset: PreviewHelper.shared.preset,
            dose: 1
        )
    }
}
