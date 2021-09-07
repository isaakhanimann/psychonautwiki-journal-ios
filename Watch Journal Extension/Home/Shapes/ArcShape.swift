import SwiftUI

struct ArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let lineWidth: CGFloat
    let insetTimes: Int

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let halfLineWidth = lineWidth/2
        let insetOneSide = halfLineWidth + CGFloat(insetTimes) * lineWidth
        let drawRect = rect.inset(by: UIEdgeInsets(
            top: insetOneSide,
            left: insetOneSide,
            bottom: insetOneSide,
            right: insetOneSide
        ))

        let center = CGPoint(x: drawRect.midX, y: drawRect.midY)
        let radius = min(drawRect.width, drawRect.height) / 2

        let delta = startAngle.positiveDistanceTo(otherAngle: endAngle)
        path.addRelativeArc(center: center, radius: radius, startAngle: startAngle, delta: delta)

        return path
    }
}
