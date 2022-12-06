import SwiftUI

struct AddCustomIngestionView: View {

    let customSubstance: CustomSubstance
    let dismiss: DismissAction
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section("Route of Administration") {
                    Picker("Route", selection: $viewModel.selectedAdministrationRoute) {
                        ForEach(AdministrationRoute.allCases) { route in
                            Text(route.rawValue)
                                .foregroundColor(.secondary)
                                .tag(route)
                        }
                    }
                }
                Section("Dose") {
                    HStack {
                        TextField("Enter Dose", text: $viewModel.selectedDoseText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text(customSubstance.unitsUnwrapped)
                    }
                    .font(.title)
                }
                Section("Time") {
                    DatePicker(
                        "Time",
                        selection: $viewModel.selectedTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                }
                Section("Color") {
                    ColorPicker(selectedColor: $viewModel.selectedColor)
                }
                EmptySectionForPadding()
                    .padding(.bottom, 50)
            }
            Button("Add to New Experience") {
                viewModel.addIngestionToNewExperience()
                dismiss()
                toastViewModel.showSuccessToast()
            }
            .buttonStyle(.primary)
            .padding()
        }
        .task {
            viewModel.customSubstance = customSubstance
            viewModel.setDefaultColor()
        }
        .navigationBarTitle("Add Ingestion")
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}
