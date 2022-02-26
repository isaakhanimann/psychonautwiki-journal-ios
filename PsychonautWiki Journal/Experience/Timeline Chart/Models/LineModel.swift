import SwiftUI

struct LineModel {
    let startLineStartPoint: DataPoint
    let startLineEndPoint: DataPoint
    let onsetCurve: Curve
    let peakLineEndPoint: DataPoint
    let offsetCurve: Curve

    init(normalizedXValuesForModel: NormalizedDataPoints) {
        self.startLineStartPoint = normalizedXValuesForModel.ingest
        self.startLineEndPoint = normalizedXValuesForModel.onsetStart
        self.onsetCurve = Curve(
            startPoint: normalizedXValuesForModel.onsetStart,
            endPoint: normalizedXValuesForModel.peakStart)
        self.peakLineEndPoint = normalizedXValuesForModel.peakEnd
        self.offsetCurve = Curve(
            startPoint: normalizedXValuesForModel.peakEnd,
            endPoint: normalizedXValuesForModel.offsetEnd)
    }

    struct NormalizedDataPoints {
        let ingest: DataPoint
        let onsetStart: DataPoint
        let peakStart: DataPoint
        let peakEnd: DataPoint
        let offsetEnd: DataPoint

        init?(
            horizontalWeight: Double,
            verticalWeight: CGFloat,
            durations: RoaDuration,
            ingestionTimeOffset: TimeInterval,
            totalGraphDuration: TimeInterval
        ) {
            guard let onset = durations.onset?.oneValue(at: 0.5) else {return nil}
            guard let comeup = durations.comeup?.oneValue(at: 0.5) else {return nil}
            guard let peak = durations.peak?.oneValue(at: horizontalWeight) else {return nil}
            guard let offset = durations.offset?.oneValue(at: horizontalWeight) else {return nil}

            let onsetStartX = ingestionTimeOffset + onset
            let peakStartX = onsetStartX + comeup
            let peakEndX = peakStartX + peak
            let offsetEndX = peakEndX + offset

            let minY: CGFloat = 0
            let maxY = verticalWeight

            self.ingest = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: ingestionTimeOffset,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.onsetStart = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: onsetStartX,
                    comparedTo: totalGraphDuration),
                yValue: minY)
            self.peakStart = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: peakStartX,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
            self.peakEnd = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: peakEndX,
                    comparedTo: totalGraphDuration),
                yValue: maxY)
            self.offsetEnd = DataPoint(
                xValue: IngestionLineModel.getNormalizedValue(
                    of: offsetEndX,
                    comparedTo: totalGraphDuration
                ),
                yValue: minY
            )
        }
    }

}
