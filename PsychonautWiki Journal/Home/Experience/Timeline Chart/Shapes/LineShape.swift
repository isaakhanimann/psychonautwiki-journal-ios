import SwiftUI

/// Draws a line
struct LineShape: Shape {
    let lineModel: LineModel
    let lineWidth: CGFloat
    let insetTimes: Int

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let halfLineWidth = lineWidth/2
        let insets = UIEdgeInsets(
            top: CGFloat(insetTimes) * lineWidth + halfLineWidth,
            left: halfLineWidth,
            bottom: halfLineWidth,
            right: halfLineWidth
        )
        let drawRect = rect.inset(by: insets)

        // Start
        var destination = getCGPoint(for: lineModel.startLineStartPoint, inside: drawRect)
        path.move(to: destination)

        // Start Line
        destination = getCGPoint(for: lineModel.startLineEndPoint, inside: drawRect)
        path.addLine(to: destination)

        // Curve Up
        destination = getCGPoint(for: lineModel.onsetCurve.endPoint, inside: drawRect)
        var control1 = getCGPoint(for: lineModel.onsetCurve.controlPoint0, inside: drawRect)
        var control2 = getCGPoint(for: lineModel.onsetCurve.controlPoint1, inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Peak Line
        destination = getCGPoint(for: lineModel.peakLineEndPoint, inside: drawRect)
        path.addLine(to: destination)

        // Curve Down
        destination = getCGPoint(for: lineModel.offsetCurve.endPoint, inside: drawRect)
        control1 = getCGPoint(for: lineModel.offsetCurve.controlPoint0, inside: drawRect)
        control2 = getCGPoint(for: lineModel.offsetCurve.controlPoint1, inside: drawRect)
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
