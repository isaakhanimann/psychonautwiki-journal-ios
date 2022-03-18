import SwiftUI

struct AddCustomIngestionView: View {

    let customSubstance: CustomSubstance
    @EnvironmentObject var sheetContext: AddIngestionSheetContext
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
            if let experienceUnwrap = sheetContext.experience {
                Button("Add Ingestion") {
                    viewModel.addIngestion(to: experienceUnwrap)
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
                            viewModel.addIngestion(to: lastExperienceUnwrap)
                            sheetContext.isShowingAddIngestionSheet.toggle()
                            sheetContext.showSuccessToast()
                        }
                        .padding(.horizontal)
                    }
                    Button("Add to New Experience") {
                        viewModel.addIngestionToNewExperience()
                        sheetContext.isShowingAddIngestionSheet.toggle()
                        sheetContext.showSuccessToast()
                    }
                    .padding()
                }
                .buttonStyle(.primary)
            }
        }
        .task {
            viewModel.customSubstance = customSubstance
            if sheetContext.experience == nil {
                viewModel.lastExperience = PersistenceController.shared.getLatestExperience()
            }
        }
        .navigationBarTitle("Add Ingestion")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    sheetContext.isShowingAddIngestionSheet.toggle()
                }
            }
        }
    }
}

struct AddCustomIngestionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomIngestionView(
            customSubstance: PreviewHelper.shared.customSubstance
        )
    }
}
