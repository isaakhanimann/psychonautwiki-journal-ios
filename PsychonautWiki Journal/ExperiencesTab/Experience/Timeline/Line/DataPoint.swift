import SwiftUI

// (0,0) = bottom/left, (1,1) = top/right
struct DataPoint {
    let xValue: Double
    let yValue: Double

    init(xValue: Double, yValue: Double) {
        assert(xValue >= 0 && xValue <= 1)
        assert(yValue >= 0 && yValue <= 1)
        self.xValue = xValue
        self.yValue = yValue
    }

    func toCGPoint(inside rect: CGRect) -> CGPoint {
        // swiftlint:disable identifier_name
        var x = xValue * rect.width
        var y = yValue * rect.height
        y = rect.height - y
        x += rect.minX
        y += rect.minY
        return CGPoint(x: x, y: y)
    }
}
