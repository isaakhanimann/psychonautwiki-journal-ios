import SwiftUI

struct EditIngestionView: View {

    @ObservedObject var ingestion: Ingestion
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Form {
            if let administrationRoutesUnwrapped = ingestion.substance?.administrationRoutesUnwrapped,
               administrationRoutesUnwrapped.count > 1 {
                Section(header: Text("Route of Administration")) {
                    Picker("Route", selection: $viewModel.selectedAdministrationRoute) {
                        ForEach(administrationRoutesUnwrapped, id: \.self) { route in
                            Text(route.displayString).tag(route)
                        }
                    }
                }
            }
            Section(
                header: Text("Dose"),
                footer: Text(Constants.doseDisclaimer)
            ) {
                DoseView(roaDose: viewModel.roaDose)
                DosePicker(
                    roaDose: viewModel.roaDose,
                    doseMaybe: $viewModel.selectedDose
                )
            }
            .listRowSeparator(.hidden)
            Section(header: Text("Time")) {
                DatePicker("Time", selection: $viewModel.selectedTime, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
            }

            Section(header: Text("Color")) {
                LazyVGrid(columns: colorColumns) {
                    ForEach(Ingestion.IngestionColor.allCases, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }
        }
        .task {
            viewModel.ingestion = ingestion
            viewModel.selectedAdministrationRoute = ingestion.administrationRouteUnwrapped
            viewModel.selectedDose = ingestion.doseUnwrapped
            viewModel.selectedColor = ingestion.colorUnwrapped
            viewModel.selectedTime = ingestion.timeUnwrapped
        }
        .navigationTitle(ingestion.substanceNameUnwrapped)
        .onDisappear(perform: viewModel.updateAndSave)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    private func colorButton(for color: Ingestion.IngestionColor) -> some View {
        ZStack {
            Color.from(ingestionColor: color)
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

struct EditIngestionView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        EditIngestionView(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!)
            .environmentObject(helper.experiences.first!)
    }
}
