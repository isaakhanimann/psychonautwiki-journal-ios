import SwiftUI

struct PresetChooseTimeAndColorsView: View {

    let preset: Preset
    let dose: Double
    @EnvironmentObject private var addIngestionContext: AddIngestionSheetContext
    @EnvironmentObject private var sheetViewModel: SheetViewModel
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @StateObject private var viewModel = ViewModel()
    @State private var hasPressedDismiss = false

    var body: some View {
        if !hasPressedDismiss {
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
                if let experienceUnwrap = addIngestionContext.experience {
                    Button("Add Ingestion") {
                        viewModel.addIngestions(to: experienceUnwrap)
                        dismissSheet()
                        toastViewModel.showSuccessToast()
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
                                dismissSheet()
                                toastViewModel.showSuccessToast()
                            }
                            .padding(.horizontal)
                        }
                        Button("Add to New Experience") {
                            viewModel.addIngestionsToNewExperience()
                            dismissSheet()
                            toastViewModel.showSuccessToast()
                        }
                        .padding()
                    }
                    .buttonStyle(.primary)
                }
            }
            .task {
                viewModel.presetDose = dose
                if addIngestionContext.experience == nil {
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
                        dismissSheet()
                    }
                }
            }
        } else {
            Text("Please Swipe Down To Dismiss")
        }
    }

    private func dismissSheet() {
        sheetViewModel.dismiss()
        // this is here because there is a SwiftUI bug that sometimes prevents the sheet from being dismissable
        // the delay makes sure that one can't see the UI change in case the sheet is being dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasPressedDismiss = true
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
