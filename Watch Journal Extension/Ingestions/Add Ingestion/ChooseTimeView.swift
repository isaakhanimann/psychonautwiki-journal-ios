import SwiftUI

struct ChooseTimeView: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dose: Double
    let dismiss: () -> Void
    let experience: Experience

    @State private var weekday: Int
    @State private var hour: Int
    @State private var minute: Int

    var selectedTime: Date {

        var components = DateComponents()
        components.weekday = weekday + 1
        components.hour = hour
        components.minute = minute

        return Calendar.current.date(from: components) ?? Date()
    }

    init(
        substance: Substance,
        administrationRoute: Roa.AdministrationRoute,
        dose: Double,
        dismiss: @escaping () -> Void,
        experience: Experience
    ) {
        self.substance = substance
        self.administrationRoute = administrationRoute
        self.dose = dose
        self.dismiss = dismiss
        self.experience = experience

        let calendar = Calendar.current

        let date = Date()
        let weekday = calendar.component(.weekday, from: date) - 1
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        self._weekday = State(wrappedValue: weekday)
        self._hour = State(wrappedValue: hour)
        self._minute = State(wrappedValue: minute)
    }

    var body: some View {
        VStack {
            HStack {
                Picker("Day", selection: $weekday) {
                    ForEach(0..<7) { option in
                        Text("\(DateFormatter().shortWeekdaySymbols[option])").tag(option)
                    }
                }
                Picker("Hour", selection: $hour) {
                    ForEach(0..<24) { option in
                        Text("\(option)").tag(option)
                    }
                }
                Text(":")
                Picker("Minute", selection: $minute) {
                    ForEach(0..<60) { option in
                        Text("\(option)").tag(option)
                    }
                }
            }

            NavigationLink(
                destination: ChooseColor(
                    substance: substance,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    dismiss: dismiss,
                    experience: experience,
                    ingestionTime: selectedTime
                ),
                label: {
                    Text("Next")
                }
            )
            .buttonStyle(BorderedButtonStyle(tint: .accentColor))
            .padding(.top)
        }
        .navigationTitle("Choose Time")
    }
}

struct ChooseTimeView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseTimeView(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dose: 20,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
