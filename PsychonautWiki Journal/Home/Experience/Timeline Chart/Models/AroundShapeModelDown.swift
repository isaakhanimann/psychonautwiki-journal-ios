import SwiftUI

struct AroundShapeModelDown: AroundShapeModel {
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

        init(
            verticalWeight: CGFloat,
            durations: DurationTypes,
            ingestionTimeOffset: TimeInterval,
            totalGraphDuration: TimeInterval
        ) {
            let minY: CGFloat = 0
            let maxY: CGFloat = verticalWeight

            self.bottomLeft = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + durations.onset!.minSec
                        + durations.comeup!.minSec
                        + durations.peak!.minSec
                        + durations.offset!.minSec,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.bottomRight = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + durations.onset!.maxSec
                        + durations.comeup!.maxSec
                        + durations.peak!.maxSec
                        + durations.offset!.maxSec,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.topRight = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + durations.onset!.maxSec
                        + durations.comeup!.maxSec
                        + durations.peak!.maxSec,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
            self.topLeft = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + durations.onset!.minSec
                        + durations.comeup!.minSec
                        + durations.peak!.minSec,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
        }
    }
}
