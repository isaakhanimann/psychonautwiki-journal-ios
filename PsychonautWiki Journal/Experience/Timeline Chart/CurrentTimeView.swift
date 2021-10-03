import SwiftUI

struct CurrentTimeView: View {

    let currentTime: Date
    let graphStartTime: Date
    let graphEndTime: Date

    var xValue: CGFloat {
        let graphLength = graphStartTime.distance(to: graphEndTime)
        let time = graphStartTime.distance(to: currentTime)
        return CGFloat(time) / CGFloat(graphLength)
    }

    var body: some View {
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
