import Foundation

extension LineShape {
    struct ViewModel {

        let startLineStartPoint: DataPoint
        let startLineEndPoint: DataPoint
        let onsetCurve: Curve
        let peakLineEndPoint: DataPoint
        let offsetCurve: Curve
        let insetIndex: Int
        let lineWidth: Double

        init?(
            timelineContext: IngestionWithTimelineContext,
            roaDuration: RoaDuration?,
            ingestionTime: Date,
            horizontalWeight: Double,
            lineWidth: Double
        ) {
            self.insetIndex = timelineContext.insetIndex
            self.lineWidth = lineWidth
            guard let roaDuration = roaDuration else {
                return nil
            }
            let offset = timelineContext.graphStartTime.distance(to: ingestionTime)
            let total = timelineContext.graphStartTime.distance(to: timelineContext.graphEndTime)
            guard let normalized = NormalizedDataPoints(
                horizontalWeight: horizontalWeight,
                verticalWeight: timelineContext.verticalWeight,
                durations: roaDuration,
                ingestionTimeOffset: offset,
                totalGraphDuration: total
            ) else {
                return nil
            }
            self.startLineStartPoint = normalized.ingest
            self.startLineEndPoint = normalized.onsetStart
            self.onsetCurve = Curve(
                startPoint: normalized.onsetStart,
                endPoint: normalized.peakStart
            )
            self.peakLineEndPoint = normalized.peakEnd
            self.offsetCurve = Curve(
                startPoint: normalized.peakEnd,
                endPoint: normalized.offsetEnd
            )
        }
    }

    struct NormalizedDataPoints {
        let ingest: DataPoint
        let onsetStart: DataPoint
        let peakStart: DataPoint
        let peakEnd: DataPoint
        let offsetEnd: DataPoint

        init?(
            horizontalWeight: Double,
            verticalWeight: Double,
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
            let minY: Double = 0
            let maxY = verticalWeight
            self.ingest = DataPoint(
                xValue: ingestionTimeOffset.ratio(to: totalGraphDuration),
                yValue: minY)
            self.onsetStart = DataPoint(
                xValue: onsetStartX.ratio(to: totalGraphDuration),
                yValue: minY)
            self.peakStart = DataPoint(
                xValue: peakStartX.ratio(to: totalGraphDuration),
                yValue: maxY)
            self.peakEnd = DataPoint(
                xValue: peakEndX.ratio(to: totalGraphDuration),
                yValue: maxY)
            self.offsetEnd = DataPoint(
                xValue: offsetEndX.ratio(to: totalGraphDuration),
                yValue: minY
            )
        }
    }
}
