import SwiftUI

struct ClockHands: View {

    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    @State private var hourAngle = AngleModel.getAngle(from: Date())
    @State private var minuteAngle = ClockHands.getMinuteAngle(from: Date())

    var body: some View {
        ZStack {
            ClockHand(angle: hourAngle, length: .hour)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))

            ClockHand(angle: minuteAngle, length: .minute)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))

        }
        .onReceive(timer) { _ in
            hourAngle = AngleModel.getAngle(from: Date())
            minuteAngle = ClockHands.getMinuteAngle(from: Date())
        }
    }

    static func getMinuteAngle(from date: Date) -> Angle {
        let calendar = Calendar.current

        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        let timeInSeconds = TimeInterval(minute * 60 + second)
        let secondsInClock: TimeInterval = 3600

        return Angle(degrees: timeInSeconds / secondsInClock * 360)
    }
}

struct HourClockHand_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height)
            ClockHands()
                .frame(width: squareSize, height: squareSize)
                .padding(10)
        }

    }
}
