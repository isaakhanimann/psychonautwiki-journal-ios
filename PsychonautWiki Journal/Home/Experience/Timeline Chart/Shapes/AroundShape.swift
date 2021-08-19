import SwiftUI

struct AroundShape: Shape {
    let aroundShapeModel: AroundShapeModel

    func path(in rect: CGRect) -> Path {

        var path = Path()

        // Start
        var destination = getCGPoint(for: aroundShapeModel.bottomLeft, inside: rect)
        path.move(to: destination)

        // Bottom Line
        destination = getCGPoint(for: aroundShapeModel.bottomRight, inside: rect)
        path.addLine(to: destination)

        // Curve Up
        destination = getCGPoint(for: aroundShapeModel.curveToTopRight.endPoint, inside: rect)
        var control1 = getCGPoint(for: aroundShapeModel.curveToTopRight.controlPoint0, inside: rect)
        var control2 = getCGPoint(for: aroundShapeModel.curveToTopRight.controlPoint1, inside: rect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Top Line
        destination = getCGPoint(for: aroundShapeModel.topLeft, inside: rect)
        path.addLine(to: destination)

        // Curve Down
        destination = getCGPoint(for: aroundShapeModel.curveToBottomLeft.endPoint, inside: rect)
        control1 = getCGPoint(for: aroundShapeModel.curveToBottomLeft.controlPoint0, inside: rect)
        control2 = getCGPoint(for: aroundShapeModel.curveToBottomLeft.controlPoint1, inside: rect)
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
