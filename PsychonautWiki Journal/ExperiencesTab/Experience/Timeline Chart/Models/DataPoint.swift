import SwiftUI

struct DataPoint {
    let xValue: CGFloat
    let yValue: CGFloat

    init(xValue: CGFloat, yValue: CGFloat) {
        assert(xValue >= 0 && xValue <= 1)
        assert(yValue >= 0 && yValue <= 1)
        self.xValue = xValue
        self.yValue = yValue
    }
}
