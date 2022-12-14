import SwiftUI

struct ChooseTimeAndColor: View {

    let substanceName: String
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    let isEstimate: Bool
    let dismiss: () -> Void
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
                Section("Notes") {
                    TextField("Notes", text: $viewModel.enteredNote)
                        .autocapitalization(.sentences)
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
                viewModel.addIngestion(
                    substanceName: substanceName,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    units: units,
                    isEstimate: isEstimate
                )
                dismiss()
                toastViewModel.showSuccessToast()
            }
            .buttonStyle(.primary)
            .padding()
        }
        .task {
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
