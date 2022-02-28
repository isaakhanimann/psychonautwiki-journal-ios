import SwiftUI

struct CurveTop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startPoint = DataPoint(xValue: 0, yValue: 1).toCGPoint(inside: rect)
        path.move(to: startPoint)
        let endPoint = DataPoint(xValue: 1, yValue: 1).toCGPoint(inside: rect)
        path.addLine(to: endPoint)
        return path
    }
}
