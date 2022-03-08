import SwiftUI

struct CurrentTimeShape: Shape {
    let xValue: CGFloat

    func path(in rect: CGRect) -> Path {
        assert(xValue >= 0 && xValue <= 1)
        var path = Path()
        let lowerPoint = getLowerCGPoint(for: xValue, inside: rect)
        let upperPoint = getUpperCGPoint(for: xValue, inside: rect)
        path.move(to: lowerPoint)
        path.addLine(to: upperPoint)
        return path
    }

    private func getLowerCGPoint(for xValue: CGFloat, inside rect: CGRect) -> CGPoint {
        // swiftlint:disable identifier_name
        var x: CGFloat = xValue * rect.width
        var y: CGFloat = 0
        y = rect.height - y
        x += rect.minX
        y += rect.minY
        return CGPoint(x: x, y: y)
    }

    private func getUpperCGPoint(for xValue: CGFloat, inside rect: CGRect) -> CGPoint {
        // swiftlint:disable identifier_name
        var x: CGFloat = xValue * rect.width
        var y: CGFloat = rect.height
        y = rect.height - y
        x += rect.minX
        y += rect.minY
        return CGPoint(x: x, y: y)
    }
}
