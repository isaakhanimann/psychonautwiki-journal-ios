import SwiftUI

struct CurrentTimeView: View {

    let startTime: Date
    let endTime: Date

    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    @State private var currentTime = Date()

    var isCurrentTimeInChart: Bool {
        currentTime > startTime && currentTime < endTime
    }

    var xValue: CGFloat {
        let graphLength = startTime.distance(to: endTime)
        let time = startTime.distance(to: currentTime)
        return CGFloat(time) / CGFloat(graphLength)
    }

    var body: some View {
        Group {
            if isCurrentTimeInChart {
                CurrentTimeShape(xValue: xValue)
                    .stroke(
                        Color.primary,
                        style: StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [7, 10],
                            dashPhase: 0
                        )
                    )
            } else {
                EmptyView()
            }
        }
        .onReceive(timer) { newTime in
            currentTime = newTime
        }
    }
}
