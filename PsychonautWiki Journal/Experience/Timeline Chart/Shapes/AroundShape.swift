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
        var destination = getCGPoint(for: aroundShapeModel.bottomLeft, inside: drawRect)
        path.move(to: destination)

        // Bottom Line
        destination = getCGPoint(for: aroundShapeModel.bottomRight, inside: drawRect)
        path.addLine(to: destination)

        // Curve Up
        destination = getCGPoint(for: aroundShapeModel.curveToTopRight.endPoint, inside: drawRect)
        var control1 = getCGPoint(for: aroundShapeModel.curveToTopRight.controlPoint0, inside: drawRect)
        var control2 = getCGPoint(for: aroundShapeModel.curveToTopRight.controlPoint1, inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Top Line
        destination = getCGPoint(for: aroundShapeModel.topLeft, inside: drawRect)
        path.addLine(to: destination)

        // Curve Down
        destination = getCGPoint(for: aroundShapeModel.curveToBottomLeft.endPoint, inside: drawRect)
        control1 = getCGPoint(for: aroundShapeModel.curveToBottomLeft.controlPoint0, inside: drawRect)
        control2 = getCGPoint(for: aroundShapeModel.curveToBottomLeft.controlPoint1, inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        return path
    }

    private func getCGPoint(for dataPoint: DataPoint, inside rect: CGRect) -> CGPoint {
        // swiftlint:disable identifier_name
        var x = dataPoint.xValue * rect.width
        var y = dataPoint.yValue * rect.height

        y = rect.height - y

        x += rect.minX
        y += rect.minY

        return CGPoint(x: x, y: y)
    }
}
