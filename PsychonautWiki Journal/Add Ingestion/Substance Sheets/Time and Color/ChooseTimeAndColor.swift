import SwiftUI

struct ChooseTimeAndColor: View {

    let substanceName: String
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    let dismiss: DismissAction
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @StateObject var viewModel = ViewModel()

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
                    .datePickerStyle(.wheel)
                    if let experience = viewModel.closestExperience {
                        Toggle("Part of \(experience.titleUnwrapped)", isOn: $viewModel.isAddingToFoundExperience)
                    }
                }
                if !viewModel.doesCompanionExistAlready {
                    Section("Choose Color") {
                        ColorPicker(
                            selectedColor: $viewModel.selectedColor,
                            alreadyUsedColors: viewModel.alreadyUsedColors,
                            otherColors: viewModel.otherColors
                        )
                    }
                }
            }
            Button("Add Ingestion") {
                viewModel.addIngestion()
                dismiss()
                toastViewModel.showSuccessToast()
            }
            .buttonStyle(.primary)
            .padding()
        }
        .task {
            viewModel.substanceName = substanceName
            viewModel.administrationRoute = administrationRoute
            viewModel.dose = dose ?? 0
            viewModel.units = units
            viewModel.initializeColorAndHasCompanion(for: substanceName)
        }
        .navigationBarTitle("Ingestion Time")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}
