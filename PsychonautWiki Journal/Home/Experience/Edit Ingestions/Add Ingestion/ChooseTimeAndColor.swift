import SwiftUI

struct ChooseTimeAndColor: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dose: Double
    let dismiss: () -> Void

    @EnvironmentObject var experience: Experience
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var calendarWrapper: CalendarWrapper

    @State private var selectedTime = Date()
    @State private var selectedColor: Ingestion.IngestionColor

    init(
        substance: Substance,
        administrationRoute: Roa.AdministrationRoute,
        dose: Double,
        dismiss: @escaping () -> Void
    ) {
        self.substance = substance
        self.administrationRoute = administrationRoute
        self.dose = dose
        self.dismiss = dismiss

        self._selectedColor = State(wrappedValue: Ingestion.IngestionColor.allCases.randomElement()!)
        let defaults = UserDefaults.standard
        let savedObject = defaults.object(forKey: substance.nameUnwrapped)
        if let savedColorString = savedObject as? String {
            if let savedColor = Ingestion.IngestionColor(rawValue: savedColorString) {
                self._selectedColor = State(wrappedValue: savedColor)
            }
        }
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Time")) {
                    DatePicker(
                        "Time",
                        selection: $selectedTime
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                }

                Section(header: Text("Color")) {
                    LazyVGrid(columns: colorColumns) {
                        ForEach(Ingestion.IngestionColor.allCases, id: \.self, content: colorButton)
                    }
                    .padding(.vertical)
                }

            }
            Button("Add Ingestion", action: addIngestion)
                .buttonStyle(PrimaryButtonStyle())
                .padding()
        }

        .navigationBarTitle("Choose Time")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Button("Cancel", action: dismiss)
            }
        }
    }

    private func addIngestion() {
        let ingestion = Ingestion(context: moc)
        ingestion.experience = experience
        ingestion.time = selectedTime
        ingestion.dose = dose
        ingestion.administrationRoute = administrationRoute.rawValue
        ingestion.substanceCopy = SubstanceCopy(basedOn: substance, context: moc)
        ingestion.color = selectedColor.rawValue
        substance.lastUsedDate = Date()
        substance.category!.file!.lastUsedSubstance = substance

        save()
        let defaults = UserDefaults.standard
        defaults.setValue(selectedColor.rawValue, forKey: substance.nameUnwrapped)
        dismiss()
    }

    private func save() {
        if moc.hasChanges {
            calendarWrapper.createOrUpdateEventBeforeMocSave(from: experience)
            do {
                try moc.save()
            } catch {
                assertionFailure(error.localizedDescription)
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

            if color == selectedColor {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            selectedColor = color
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            color == selectedColor
                ? [.isButton, .isSelected]
                : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(color.rawValue))
    }
}

struct ChooseTimeAndColor_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        return ChooseTimeAndColor(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dose: 10,
            dismiss: {}
        )
    }
}
