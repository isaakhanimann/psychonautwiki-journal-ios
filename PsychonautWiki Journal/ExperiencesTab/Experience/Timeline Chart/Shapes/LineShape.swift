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
        var destination = lineModel.startLineStartPoint.toCGPoint(inside: drawRect)
        path.move(to: destination)

        // Start Line
        destination = lineModel.startLineEndPoint.toCGPoint(inside: drawRect)
        path.addLine(to: destination)

        // Curve Up
        destination = lineModel.onsetCurve.endPoint.toCGPoint(inside: drawRect)
        var control1 = lineModel.onsetCurve.controlPoint0.toCGPoint(inside: drawRect)
        var control2 = lineModel.onsetCurve.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        // Peak Line
        destination = lineModel.peakLineEndPoint.toCGPoint(inside: drawRect)
        path.addLine(to: destination)

        // Curve Down
        destination = lineModel.offsetCurve.endPoint.toCGPoint(inside: drawRect)
        control1 = lineModel.offsetCurve.controlPoint0.toCGPoint(inside: drawRect)
        control2 = lineModel.offsetCurve.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)

        return path
    }
}
