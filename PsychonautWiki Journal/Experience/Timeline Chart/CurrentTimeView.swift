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
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 0) {
                Text(currentTime.asTimeString)
                    .font(.title2)
                    .offset(x: getXOffsetFromCenter(width: geo.size.width), y: 0)

                CurrentTimeShape(xValue: xValue)
                    .stroke(
                        Color.primary,
                        style: StrokeStyle(
                            lineWidth: 3,
                            lineCap: .butt,
                            lineJoin: .miter,
                            miterLimit: 0,
                            dash: [7, 10],
                            dashPhase: 0
                        )
                    )
            }
        }
    }

    private func getXOffsetFromCenter(width: CGFloat) -> CGFloat {
        let xCenter = 0.5 * width
        let xPosition = xValue * width
        return xPosition - xCenter
    }
}
