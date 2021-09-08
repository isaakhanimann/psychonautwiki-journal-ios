import SwiftUI

struct ClockHands: View {

    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    @State private var hourAngle = AngleModel.getAngle(from: Date())
    @State private var minuteAngle = ClockHands.getMinuteAngle(from: Date())

    let circleSize: CGFloat = 6

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
                ClockHand(
                    angle: minuteAngle,
                    ringLength: circleSize/2,
                    thinLength: thinLength,
                    thickLength: minuteLength
                )

                Circle()
                    .strokeBorder()
                    .frame(width: circleSize, height: circleSize)

            }
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
