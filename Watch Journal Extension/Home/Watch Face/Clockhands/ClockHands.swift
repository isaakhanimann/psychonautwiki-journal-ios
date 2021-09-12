import SwiftUI

struct ClockHands: View {

    let style: ClockHandStyle

    let hourAngle: Angle
    let minuteAngle: Angle
    let circleSize: CGFloat = 6

    init(timeToDisplay: Date, style: ClockHandStyle) {
        self.style = style
        self.hourAngle = AngleModel.getAngle(from: timeToDisplay)
        self.minuteAngle = ClockHands.getMinuteAngle(from: timeToDisplay)
    }

    enum ClockHandStyle {
        case hourAndMinute, justHour
    }

    var body: some View {
        GeometryReader { geometry in
            let radius: CGFloat = min(geometry.size.width, geometry.size.height) / 2
            let thinLength =  1/6 * radius
            let hourLength = 2/5 * radius
            let minuteLength = 5/7 * radius
            ZStack {
                ClockHand(
                    angle: hourAngle,
                    ringLength: circleSize/2,
                    thinLength: thinLength,
                    thickLength: hourLength
                )

                if style == .hourAndMinute {
                    ClockHand(
                        angle: minuteAngle,
                        ringLength: circleSize/2,
                        thinLength: thinLength,
                        thickLength: minuteLength
                    )
                }

                Circle()
                    .strokeBorder()
                    .frame(width: circleSize, height: circleSize)

            }
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

struct ClockHandsTime_Previews: PreviewProvider {
    static var previews: some View {
        var components = DateComponents()
        components.hour = 10
        components.minute = 10
        let sampleDate = Calendar.current.date(from: components) ?? Date()
        return ClockHands(timeToDisplay: sampleDate, style: .hourAndMinute)
    }
}
