import Foundation

struct Curve {
    let endPoint: DataPoint
    let controlPoint0: DataPoint
    let controlPoint1: DataPoint

    init(startPoint: DataPoint, endPoint: DataPoint) {
        self.endPoint = endPoint
        let middleX = (startPoint.xValue + endPoint.xValue) / 2
        self.controlPoint0 = DataPoint(
            xValue: middleX,
            yValue: startPoint.yValue)
        self.controlPoint1 = DataPoint(
            xValue: middleX,
            yValue: endPoint.yValue)
    }
}
