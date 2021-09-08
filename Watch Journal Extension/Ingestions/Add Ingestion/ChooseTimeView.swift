import SwiftUI

struct ChooseTimeView: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dose: Double
    let dismiss: () -> Void
    let experience: Experience

    let yesterday: Date
    let today: Date
    let tomorrow: Date

    @State private var day: Days
    @State private var hour: Int
    @State private var minute: Int

    enum Days {
        case yesterday, today, tomorrow
    }

    var selectedTime: Date {
        let calendar = Calendar.current

        var components = DateComponents()
        var dayDate: Date
        switch day {
        case .yesterday:
            dayDate = yesterday
        case .today:
            dayDate = today
        case .tomorrow:
            dayDate = tomorrow
        }
        components.year = calendar.component(.year, from: dayDate)
        components.month = calendar.component(.month, from: dayDate)
        components.day = calendar.component(.day, from: dayDate)
        components.hour = hour
        components.minute = minute

        let date = calendar.date(from: components) ?? Date()
        return date
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
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        self._day = State(wrappedValue: .today)
        self._hour = State(wrappedValue: hour)
        self._minute = State(wrappedValue: minute)

        self.yesterday = Date().addingTimeInterval(-86400)
        self.today = Date()
        self.tomorrow = Date().addingTimeInterval(86400)
    }

    var body: some View {
        VStack {
            HStack {
                Picker("Day", selection: $day) {
                    ForEach([Days.yesterday, .today, .tomorrow], id: \.self) { option in
                        Text(getWeekDay(of: option)).tag(option)
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

    private func getWeekDay(of days: Days) -> String {
        switch days {
        case .yesterday:
            return "\(DateFormatter().shortWeekdaySymbols[Calendar.current.component(.weekday, from: yesterday)-1])"
        case .today:
            return "\(DateFormatter().shortWeekdaySymbols[Calendar.current.component(.weekday, from: today)-1])"
        case .tomorrow:
            return "\(DateFormatter().shortWeekdaySymbols[Calendar.current.component(.weekday, from: tomorrow)-1])"
        }
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
