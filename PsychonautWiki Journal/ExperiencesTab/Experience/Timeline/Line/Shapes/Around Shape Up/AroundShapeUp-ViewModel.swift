import Foundation

extension AroundShapeUp {

    class ViewModel {
        let bottomLeft: DataPoint
        let bottomRight: DataPoint
        let curveToTopRight: Curve
        let topLeft: DataPoint
        let curveToBottomLeft: Curve
        let insetIndex: Int
        let lineWidth: Double

        init?(timelineContext: IngestionWithTimelineContext,
              lineWidth: Double
        ) {
            self.insetIndex = timelineContext.insetIndex
            self.lineWidth = lineWidth
            let ingestion = timelineContext.ingestion
            guard let roaDuration = ingestion.substance?.getDuration(for: ingestion.administrationRouteUnwrapped) else {
                return nil
            }
            let offset = timelineContext.graphStartTime.distance(to: ingestion.timeUnwrapped)
            let total = timelineContext.graphStartTime.distance(to: timelineContext.graphEndTime)
            guard let normalizedPoints = NormalizedAroundShape(
                verticalWeight: timelineContext.verticalWeight,
                durations: roaDuration,
                ingestionTimeOffset: offset,
                totalGraphDuration: total
            ) else {return nil}
            self.bottomLeft = normalizedPoints.bottomLeft
            self.bottomRight = normalizedPoints.bottomRight
            self.curveToTopRight = Curve(
                startPoint: normalizedPoints.bottomRight,
                endPoint: normalizedPoints.topRight
            )
            self.topLeft = normalizedPoints.topLeft
            self.curveToBottomLeft = Curve(
                startPoint: normalizedPoints.topLeft,
                endPoint: normalizedPoints.bottomLeft
            )
        }
    }

    struct NormalizedAroundShape {
        let bottomLeft: DataPoint
        let bottomRight: DataPoint
        let topRight: DataPoint
        let topLeft: DataPoint

        init?(
            verticalWeight: Double,
            durations: RoaDuration,
            ingestionTimeOffset: TimeInterval,
            totalGraphDuration: TimeInterval
        ) {
            let minY: Double = 0
            let maxY: Double = verticalWeight
            guard let onsetMin = durations.onset?.minSec else {return nil}
            guard let onsetMax = durations.onset?.maxSec else {return nil}
            guard let comeupMin = durations.comeup?.minSec else {return nil}
            guard let comeupMax = durations.comeup?.maxSec else {return nil}
            self.bottomLeft = DataPoint(
                xValue: (ingestionTimeOffset + onsetMin).ratio(to: totalGraphDuration),
                yValue: minY)
            self.bottomRight = DataPoint(
                xValue: (ingestionTimeOffset + onsetMax).ratio(to: totalGraphDuration),
                yValue: minY)
            self.topRight = DataPoint(
                xValue: (ingestionTimeOffset
                         + onsetMax
                         + comeupMax).ratio(to: totalGraphDuration),
                yValue: maxY
            )
            self.topLeft = DataPoint(
                xValue: (ingestionTimeOffset
                         +  onsetMin
                         + comeupMin).ratio(to: totalGraphDuration),
                yValue: maxY
            )
        }
    }
}
