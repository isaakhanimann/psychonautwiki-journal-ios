import SwiftUI

struct TimeObserverView: View {

    let style: ClockHands.ClockHandStyle

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    @State private var currentTime = Date()

    var body: some View {
        ClockHands(timeToDisplay: currentTime, style: style)
        .onReceive(timer) { _ in
            withAnimation {
                currentTime = Date()
            }
        }
    }
}

struct HourClockHand_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height)
            TimeObserverView(style: .hourAndMinute)
                .frame(width: squareSize, height: squareSize)
                .padding(10)
        }

    }
}
