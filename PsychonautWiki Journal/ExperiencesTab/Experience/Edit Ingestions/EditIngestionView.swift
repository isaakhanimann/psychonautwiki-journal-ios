import SwiftUI

struct EditIngestionView: View {

    @ObservedObject var ingestion: Ingestion
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Form {
            Section(header: Text("Substance")) {
                TextField("Name", text: $viewModel.selectedName)
                    .disableAutocorrection(true)
            }
            routeSection
            Section(
                header: Text("\(viewModel.selectedAdministrationRoute.rawValue) Dose"),
                footer: Text(ChooseDoseView.doseDisclaimer)
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
                    ForEach(IngestionColor.allCases, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }
        }
        .task {
            viewModel.initialize(ingestion: ingestion)
        }
        .navigationTitle("Edit Ingestion")
        .onDisappear {
            PersistenceController.shared.saveViewContext()
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }

    private var routeSection: some View {
        Section(header: Text("Route of Administration")) {
            Picker("Route", selection: $viewModel.selectedAdministrationRoute) {
                let administrationRoutesUnwrapped = ingestion.substance?.administrationRoutesUnwrapped ?? []
                ForEach(administrationRoutesUnwrapped, id: \.self) { route in
                    Text(route.rawValue)
                        .tag(route)
                }
                let otherRoutes = AdministrationRoute.allCases.filter { route in
                    !administrationRoutesUnwrapped.contains(route)
                }
                ForEach(otherRoutes, id: \.self) { route in
                    Text(route.rawValue)
                        .foregroundColor(.secondary)
                        .tag(route)
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

struct EditIngestionView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        EditIngestionView(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!)
            .environmentObject(helper.experiences.first!)
    }
}
