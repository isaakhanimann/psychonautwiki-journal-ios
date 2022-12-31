import SwiftUI

struct FinishIngestionScreen: View {

    let substanceName: String
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    let isEstimate: Bool
    let dismiss: () -> Void
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @StateObject var viewModel = ViewModel()

    var body: some View {
        FinishIngestionContent(
            selectedTime: $viewModel.selectedTime,
            closestExperience: $viewModel.closestExperience,
            isAddingToFoundExperience: $viewModel.isAddingToFoundExperience,
            enteredNote: $viewModel.enteredNote,
            doesCompanionExistAlready: $viewModel.doesCompanionExistAlready,
            selectedColor: $viewModel.selectedColor,
            alreadyUsedColors: viewModel.alreadyUsedColors,
            otherColors: viewModel.otherColors,
            addIngestion: {
                viewModel.addIngestion(
                    substanceName: substanceName,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    units: units,
                    isEstimate: isEstimate
                )
                dismiss()
                toastViewModel.showSuccessToast()
            },
            dismiss: dismiss
        ).task {
            viewModel.initializeColorAndHasCompanion(for: substanceName)
        }
    }
}


struct FinishIngestionContent: View {

    @Binding var selectedTime: Date
    @Binding var closestExperience: Experience?
    @Binding var isAddingToFoundExperience: Bool
    @Binding var enteredNote: String
    @Binding var doesCompanionExistAlready: Bool
    @Binding var selectedColor: SubstanceColor
    let alreadyUsedColors: Set<SubstanceColor>
    let otherColors: Set<SubstanceColor>
    let addIngestion: () -> Void
    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section("Choose Time") {
                    DatePicker(
                        "Ingestion Time",
                        selection: $selectedTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    if let experience = closestExperience {
                        Toggle("Part of \(experience.titleUnwrapped)", isOn: $isAddingToFoundExperience).tint(.accentColor)
                    }
                }
                Section("Notes") {
                    TextField("Notes", text: $enteredNote)
                        .autocapitalization(.sentences)
                }
                if !doesCompanionExistAlready {
                    Section("Choose Color") {
                        ColorPicker(
                            selectedColor: $selectedColor,
                            alreadyUsedColors: alreadyUsedColors,
                            otherColors: otherColors
                        )
                    }
                }
            }
            Button("Add Ingestion") {
                addIngestion()
            }
            .buttonStyle(.primary)
            .padding()
        }
        .navigationBarTitle("Finish")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

struct FinishIngestionContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FinishIngestionContent(
                selectedTime: .constant(Date()),
                closestExperience: .constant(nil),
                isAddingToFoundExperience: .constant(false),
                enteredNote: .constant("hello"),
                doesCompanionExistAlready: .constant(false),
                selectedColor: .constant(.green),
                alreadyUsedColors: [.blue, .brown, .pink],
                otherColors: [.green, .mint, .indigo, .cyan, .purple, .orange, .red, .teal],
                addIngestion: {},
                dismiss: {}
            )
        }
    }
}
