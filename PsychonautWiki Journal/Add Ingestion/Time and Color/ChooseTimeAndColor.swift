import SwiftUI

struct ChooseTimeAndColor: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    let dismiss: (AddResult) -> Void
    let experience: Experience?
    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Time", selection: $viewModel.selectedTime, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }
                Section(header: Text("Color")) {
                    LazyVGrid(columns: colorColumns) {
                        ForEach(IngestionColor.allCases, id: \.self, content: colorButton)
                    }
                    .padding(.vertical)
                }
            }
            if let experienceUnwrap = experience {
                Button("Add Ingestion") {
                    viewModel.addIngestionSaveAndDismiss(to: experienceUnwrap)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            } else {
                VStack {
                    let twoDaysAgo = Date().addingTimeInterval(-2*24*60*60)
                    if let lastExperienceUnwrap = viewModel.lastExperience,
                       lastExperienceUnwrap.dateForSorting > twoDaysAgo {
                        Button("Add to \(lastExperienceUnwrap.titleUnwrapped)") {
                            viewModel.addIngestionSaveAndDismiss(to: lastExperienceUnwrap)
                        }
                        .padding(.horizontal)
                    }
                    Button("Add to New Experience") {
                        viewModel.addIngestionToNewExperienceSaveAndDismiss()
                    }
                    .padding()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .task {
            viewModel.substance = substance
            viewModel.administrationRoute = administrationRoute
            viewModel.dose = dose ?? 0
            viewModel.units = units
            viewModel.dismiss = dismiss
            if experience == nil {
                viewModel.setLastExperience()
            }
            viewModel.setDefaultColor()
        }
        .navigationBarTitle("Choose Time")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss(.cancelled)
                }
            }
        }
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    private func colorButton(for color: IngestionColor) -> some View {
        ZStack {
            color.swiftUIColor
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            if color == viewModel.selectedColor {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            viewModel.selectedColor = color
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            color == viewModel.selectedColor
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(color.rawValue))
    }
}

struct ChooseTimeAndColor_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        return ChooseTimeAndColor(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dose: 10,
            units: "mg",
            dismiss: {print($0)},
            experience: helper.experiences.first!
        )
    }
}
