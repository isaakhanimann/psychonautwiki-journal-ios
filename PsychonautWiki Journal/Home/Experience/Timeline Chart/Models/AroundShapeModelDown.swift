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

        // swiftlint:disable function_body_length
        init?(
            verticalWeight: CGFloat,
            durations: DurationTypes,
            ingestionTimeOffset: TimeInterval,
            totalGraphDuration: TimeInterval
        ) {
            let minY: CGFloat = 0
            let maxY: CGFloat = verticalWeight

            guard let onsetMin = durations.onset?.minSec else {return nil}
            guard let onsetMax = durations.onset?.maxSec else {return nil}
            guard let comeupMin = durations.comeup?.minSec else {return nil}
            guard let comeupMax = durations.comeup?.maxSec else {return nil}
            guard let peakMin = durations.peak?.minSec else {return nil}
            guard let peakMax = durations.peak?.maxSec else {return nil}
            guard let offsetMin = durations.offset?.minSec else {return nil}
            guard let offsetMax = durations.offset?.maxSec else {return nil}

            self.bottomLeft = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + onsetMin
                        + comeupMin
                        + peakMin
                        + offsetMin,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.bottomRight = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + onsetMax
                        + comeupMax
                        + peakMax
                        + offsetMax,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.topRight = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + onsetMax
                        + comeupMax
                        + peakMax,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
            self.topLeft = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + onsetMin
                        + comeupMin
                        + peakMin,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
        }
    }
}
