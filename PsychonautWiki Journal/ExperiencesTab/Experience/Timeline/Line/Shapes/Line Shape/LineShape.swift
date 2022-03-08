import SwiftUI

struct LineShape: Shape {

    let viewModel: ViewModel?

    init(
        ingestionLineModel: IngestionWithTimelineContext,
        graphStartTime: Date,
        graphEndTime: Date,
        lineWidth: Double
    ) {
        self.viewModel = ViewModel(
            ingestionLineModel: ingestionLineModel,
            graphStartTime: graphStartTime,
            graphEndTime: graphEndTime,
            lineWidth: lineWidth
        )
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let viewModelUnwrap = viewModel else {
            return path
        }
        let halfLineWidth = viewModelUnwrap.lineWidth/2
        let insets = UIEdgeInsets(
            top: Double(viewModelUnwrap.insetIndex) * viewModelUnwrap.lineWidth + halfLineWidth,
            left: halfLineWidth,
            bottom: halfLineWidth,
            right: halfLineWidth
        )
        let drawRect = rect.inset(by: insets)
        // Start
        var destination = viewModelUnwrap.startLineStartPoint.toCGPoint(inside: drawRect)
        path.move(to: destination)
        // Start Line
        destination = viewModelUnwrap.startLineEndPoint.toCGPoint(inside: drawRect)
        path.addLine(to: destination)
        // Curve Up
        destination = viewModelUnwrap.onsetCurve.endPoint.toCGPoint(inside: drawRect)
        var control1 = viewModelUnwrap.onsetCurve.controlPoint0.toCGPoint(inside: drawRect)
        var control2 = viewModelUnwrap.onsetCurve.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)
        // Peak Line
        destination = viewModelUnwrap.peakLineEndPoint.toCGPoint(inside: drawRect)
        path.addLine(to: destination)
        // Curve Down
        destination = viewModelUnwrap.offsetCurve.endPoint.toCGPoint(inside: drawRect)
        control1 = viewModelUnwrap.offsetCurve.controlPoint0.toCGPoint(inside: drawRect)
        control2 = viewModelUnwrap.offsetCurve.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)
        return path
    }
}
