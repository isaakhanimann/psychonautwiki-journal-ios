import SwiftUI

struct CurrentTimeView: View {

    let startTime: Date
    let endTime: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 5)) { context in
            let currentTime = context.date
            let isCurrentTimeInChart = currentTime > startTime && currentTime < endTime
            let graphLength = startTime.distance(to: endTime)
            let offset = startTime.distance(to: currentTime)
            let xValue = CGFloat(offset) / CGFloat(graphLength)
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
            }
        }
    }
}
