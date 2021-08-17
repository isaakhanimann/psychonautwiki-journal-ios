import SwiftUI

struct TimerView: View {

    @ObservedObject var experience: Experience
    var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    @State private var currentTime = Date()

    var body: some View {
        Text(timerValue)
            .foregroundColor(.secondary)
            .fixedSize()
        .onReceive(timer) { newTime in
            currentTime = newTime
        }
    }

    private let formatter = DateComponentsFormatter()

    var timerValue: String {
        guard let timeOfFirstIngestion = experience.sortedIngestionsUnwrapped.first?.timeUnwrapped else {
            return "Unknown"
        }
        let cal = Calendar.current
        guard let dateIntervalUnwrapped = cal.dateInterval(of: .second, for: timeOfFirstIngestion) else {
            return "Unknown"
        }
        let roundedTime = dateIntervalUnwrapped.start
        let difference = roundedTime.distance(to: currentTime)
        guard let stringUnwrapped = formatter.string(from: difference) else {return "Unknown"}
        return stringUnwrapped
    }
}
