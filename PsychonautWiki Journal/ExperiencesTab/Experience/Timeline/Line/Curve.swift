import Foundation

struct Curve {
    let endPoint: DataPoint
    let controlPoint0: DataPoint
    let controlPoint1: DataPoint

    init(startPoint: DataPoint, endPoint: DataPoint) {
        self.endPoint = endPoint
        let xDiff = endPoint.xValue - startPoint.xValue
        let ratio = 0.17
        self.controlPoint0 = DataPoint(
            xValue: startPoint.xValue + ratio*xDiff,
            yValue: startPoint.yValue
        )
        self.controlPoint1 = DataPoint(
            xValue: endPoint.xValue - ratio*xDiff,
            yValue: endPoint.yValue
        )
    }
}
