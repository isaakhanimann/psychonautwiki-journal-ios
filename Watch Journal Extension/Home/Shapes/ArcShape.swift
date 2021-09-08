import SwiftUI

struct ArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let lineWidth: CGFloat
    let insetPerSide: CGFloat

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let drawRect = rect.inset(by: UIEdgeInsets(
            top: insetPerSide,
            left: insetPerSide,
            bottom: insetPerSide,
            right: insetPerSide
        ))

        let center = CGPoint(x: drawRect.midX, y: drawRect.midY)
        let radius = min(drawRect.width, drawRect.height) / 2

        let delta = startAngle.positiveDistanceTo(otherAngle: endAngle)
        path.addRelativeArc(center: center, radius: radius, startAngle: startAngle, delta: delta)

        return path
    }
}
