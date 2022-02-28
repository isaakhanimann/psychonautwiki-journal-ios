import SwiftUI

struct AroundShape: Shape {
    let aroundShapeModel: AroundShapeModel
    let insetTimes: Int
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let halfLineWidth = lineWidth/2
        let insets = UIEdgeInsets(
            top: CGFloat(insetTimes) * lineWidth,
            left: halfLineWidth,
            bottom: 0,
            right: halfLineWidth
        )
        let drawRect = rect.inset(by: insets)

        // Start
        var destination = aroundShapeModel.bottomLeft.toCGPoint(inside: drawRect)
        path.move(to: destination)

        // Bottom Line
        destination = aroundShapeModel.bottomRight.toCGPoint(inside: drawRect)
        path.addLine(to: destination)

        // Curve Up
        destination = aroundShapeModel.curveToTopRight.endPoint.toCGPoint(inside: drawRect)
        var control1 = aroundShapeModel.curveToTopRight.controlPoint0.toCGPoint(inside: drawRect)
        var control2 = aroundShapeModel.curveToTopRight.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Top Line
        destination = aroundShapeModel.topLeft.toCGPoint(inside: drawRect)
        path.addLine(to: destination)

        // Curve Down
        destination = aroundShapeModel.curveToBottomLeft.endPoint.toCGPoint(inside: drawRect)
        control1 = aroundShapeModel.curveToBottomLeft.controlPoint0.toCGPoint(inside: drawRect)
        control2 = aroundShapeModel.curveToBottomLeft.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        return path
    }
}
