import SwiftUI

struct AroundShapeModelUp: AroundShapeModel {
    let bottomLeft: DataPoint
    let bottomRight: DataPoint
    let curveToTopRight: Curve
    let topLeft: DataPoint
    let curveToBottomLeft: Curve

    init(normalizedXValuesForModel: NormalizedDataPoints) {
        self.bottomLeft = normalizedXValuesForModel.bottomLeft
        self.bottomRight = normalizedXValuesForModel.bottomRight
        self.curveToTopRight = Curve(
            startPoint: normalizedXValuesForModel.bottomRight,
            endPoint: normalizedXValuesForModel.topRight
        )
        self.topLeft = normalizedXValuesForModel.topLeft
        self.curveToBottomLeft = Curve(
            startPoint: normalizedXValuesForModel.topLeft,
            endPoint: normalizedXValuesForModel.bottomLeft
        )
    }

    struct NormalizedDataPoints {
        let bottomLeft: DataPoint
        let bottomRight: DataPoint
        let topRight: DataPoint
        let topLeft: DataPoint

        init?(
            verticalWeight: CGFloat,
            durations: RoaDuration,
            ingestionTimeOffset: TimeInterval,
            totalGraphDuration: TimeInterval
        ) {
            let minY: CGFloat = 0
            let maxY: CGFloat = verticalWeight

            guard let onsetMin = durations.onset?.minSec else {return nil}
            guard let onsetMax = durations.onset?.maxSec else {return nil}
            guard let comeupMin = durations.comeup?.minSec else {return nil}
            guard let comeupMax = durations.comeup?.maxSec else {return nil}

            self.bottomLeft = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset + onsetMin,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.bottomRight = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset + onsetMax,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.topRight = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + onsetMax
                        + comeupMax,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
            self.topLeft = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        +  onsetMin
                        + comeupMin,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
        }
    }
}
