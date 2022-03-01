import SwiftUI

struct CurveUp: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startPoint = DataPoint(xValue: 0, yValue: 0).toCGPoint(inside: rect)
        path.move(to: startPoint)
        let endPoint = DataPoint(xValue: 1, yValue: 1).toCGPoint(inside: rect)
        let control1 = DataPoint(xValue: 0.1, yValue: 0).toCGPoint(inside: rect)
        let control2 = DataPoint(xValue: 0.9, yValue: 1).toCGPoint(inside: rect)
        path.addCurve(to: endPoint, control1: control1, control2: control2)
        return path
    }
}
