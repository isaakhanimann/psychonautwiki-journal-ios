import SwiftUI

struct ChooseTimeAndColor: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    @EnvironmentObject var sheetContext: AddIngestionSheetContext
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
                }
                Section("Choose Color") {
                    ColorPicker(selectedColor: $viewModel.selectedColor)
                }
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
            viewModel.substance = substance
            viewModel.administrationRoute = administrationRoute
            viewModel.dose = dose ?? 0
            viewModel.units = units
            if sheetContext.experience == nil {
                viewModel.lastExperience = PersistenceController.shared.getLatestExperience()
            }
            viewModel.setDefaultColor()
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

struct ChooseTimeAndColor_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        return ChooseTimeAndColor(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dose: 10,
            units: "mg"
        )
    }
}
