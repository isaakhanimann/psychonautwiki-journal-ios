import SwiftUI

/// Draws a shape in the form of a line
struct AroundShape: Shape {
    let aroundShapeModel: AroundShapeModel

    func path(in rect: CGRect) -> Path {

        var path = Path()

        // Start
        var destination = getCGPoint(for: aroundShapeModel.startLineStartPoint, inside: rect)
        path.move(to: destination)

        // Start Line
        destination = getCGPoint(for: aroundShapeModel.startLineEndPointBottom, inside: rect)
        path.addLine(to: destination)

        // Curve Up
        destination = getCGPoint(for: aroundShapeModel.onsetCurveBottom.endPoint, inside: rect)
        var control1 = getCGPoint(for: aroundShapeModel.onsetCurveBottom.controlPoint0, inside: rect)
        var control2 = getCGPoint(for: aroundShapeModel.onsetCurveBottom.controlPoint1, inside: rect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Peak Line
        destination = getCGPoint(for: aroundShapeModel.peakLineEndPointBottom, inside: rect)
        path.addLine(to: destination)

        // Curve Down
        destination = getCGPoint(for: aroundShapeModel.offsetCurveBottom.endPoint, inside: rect)
        control1 = getCGPoint(for: aroundShapeModel.offsetCurveBottom.controlPoint0, inside: rect)
        control2 = getCGPoint(for: aroundShapeModel.offsetCurveBottom.controlPoint1, inside: rect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // End Line
        destination = getCGPoint(for: aroundShapeModel.endLineEndPointBottom, inside: rect)
        path.addLine(to: destination)

        // Curve Back Up
        destination = getCGPoint(for: aroundShapeModel.offsetCurveTop.endPoint, inside: rect)
        control1 = getCGPoint(for: aroundShapeModel.offsetCurveTop.controlPoint0, inside: rect)
        control2 = getCGPoint(for: aroundShapeModel.offsetCurveTop.controlPoint1, inside: rect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Peak Line
        destination = getCGPoint(for: aroundShapeModel.peakLineEndPointTop, inside: rect)
        path.addLine(to: destination)

        // Curve Back Down
        destination = getCGPoint(for: aroundShapeModel.onsetCurveTop.endPoint, inside: rect)
        control1 = getCGPoint(for: aroundShapeModel.onsetCurveTop.controlPoint0, inside: rect)
        control2 = getCGPoint(for: aroundShapeModel.onsetCurveTop.controlPoint1, inside: rect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Start Line Back
        destination = getCGPoint(for: aroundShapeModel.startLineStartPoint, inside: rect)
        path.addLine(to: destination)

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
