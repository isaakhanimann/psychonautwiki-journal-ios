import SwiftUI

struct AroundShapeModel {
    let startLineStartPoint: DataPoint
    let startLineEndPointBottom: DataPoint
    let onsetCurveBottom: Curve
    let peakLineEndPointBottom: DataPoint
    let offsetCurveBottom: Curve
    let endLineEndPointBottom: DataPoint
    let offsetCurveTop: Curve
    let peakLineEndPointTop: DataPoint
    let onsetCurveTop: Curve

    init(normalizedXValuesForModel: NormalizedDataPoints) {
        self.startLineStartPoint = normalizedXValuesForModel.ingest
        self.startLineEndPointBottom = normalizedXValuesForModel.onsetBottom
        self.onsetCurveBottom = Curve(
            startPoint: normalizedXValuesForModel.onsetBottom,
            endPoint: normalizedXValuesForModel.peakStartBottom)
        self.peakLineEndPointBottom = normalizedXValuesForModel.peakEndBottom
        self.offsetCurveBottom = Curve(
            startPoint: normalizedXValuesForModel.peakEndBottom,
            endPoint: normalizedXValuesForModel.offsetEndBottom)
        self.endLineEndPointBottom = normalizedXValuesForModel.offsetEndTop
        self.offsetCurveTop = Curve(
            startPoint: normalizedXValuesForModel.offsetEndTop,
            endPoint: normalizedXValuesForModel.peakEndTop)
        self.peakLineEndPointTop = normalizedXValuesForModel.peakStartTop
        self.onsetCurveTop = Curve(
            startPoint: normalizedXValuesForModel.peakStartTop,
            endPoint: normalizedXValuesForModel.onsetTop)
    }

    struct NormalizedDataPoints {
        let ingest: DataPoint
        let onsetBottom: DataPoint
        let peakStartBottom: DataPoint
        let peakEndBottom: DataPoint
        let offsetEndBottom: DataPoint
        let offsetEndTop: DataPoint
        let peakEndTop: DataPoint
        let peakStartTop: DataPoint
        let onsetTop: DataPoint

        // swiftlint:disable function_body_length
        init(
            verticalWeight: CGFloat,
            durations: DurationTypes,
            ingestionTimeOffset: TimeInterval,
            totalGraphDuration: TimeInterval
        ) {
            let minY: CGFloat = 0
            let maxY: CGFloat = verticalWeight

            let maxTimeIngestion: TimeInterval = ingestionTimeOffset
                + durations.onset!.maxSec
                + durations.comeup!.maxSec
                + durations.peak!.maxSec
                + durations.offset!.maxSec

            self.ingest = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.onsetBottom = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset + durations.onset!.maxSec,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.peakStartBottom = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: min(
                        ingestionTimeOffset + durations.onset!.maxSec + durations.comeup!.maxSec,
                        ingestionTimeOffset + durations.onset!.minSec
                            + durations.comeup!.minSec
                            + durations.peak!.minSec),
                    comparedTo: totalGraphDuration),
                yValue: maxY)
            self.peakEndBottom = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset +  durations.onset!.minSec
                        + durations.comeup!.minSec
                        + durations.peak!.minSec,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
            self.offsetEndBottom = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset + durations.onset!.minSec
                        + durations.comeup!.minSec
                        + durations.peak!.minSec
                        + durations.offset!.minSec,
                    comparedTo: totalGraphDuration
                ),
                yValue: minY
            )
            self.offsetEndTop = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: maxTimeIngestion,
                    comparedTo: totalGraphDuration
                ),
                yValue: minY
            )
            self.peakEndTop = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + durations.onset!.maxSec
                        + durations.comeup!.maxSec
                        + durations.peak!.maxSec,
                    comparedTo: totalGraphDuration
                ),
                yValue: maxY
            )
            self.peakStartTop = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset
                        + durations.onset!.minSec
                        + durations.comeup!.minSec,
                    comparedTo: totalGraphDuration
                ),
                yValue: maxY
            )
            self.onsetTop = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset + durations.onset!.minSec,
                    comparedTo: totalGraphDuration
                ),
                yValue: minY
            )
        }
    }
}
