import SwiftUI

struct ChooseTimeAndColor: View {

    let substance: Substance
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
                Section("Choose Color") {
                    ColorPicker(selectedColor: $viewModel.selectedColor)
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
            viewModel.substance = substance
            viewModel.administrationRoute = administrationRoute
            viewModel.dose = dose ?? 0
            viewModel.units = units
            viewModel.initializeColorAndHasCompanion(for: substance.name)
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
