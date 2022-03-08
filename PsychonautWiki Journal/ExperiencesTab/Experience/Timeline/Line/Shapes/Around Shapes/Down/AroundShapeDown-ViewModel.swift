import Foundation

extension AroundShapeDown {

    class ViewModel {
        let bottomLeft: DataPoint
        let bottomRight: DataPoint
        let curveToTopRight: Curve
        let topLeft: DataPoint
        let curveToBottomLeft: Curve
        let insetIndex: Int
        let lineWidth: Double

        init?(
            ingestionLineModel: IngestionWithTimelineContext,
            graphStartTime: Date,
            graphEndTime: Date,
            lineWidth: Double
        ) {
            self.insetIndex = ingestionLineModel.insetIndex
            self.lineWidth = lineWidth
            let ingestion = ingestionLineModel.ingestion
            guard let roaDuration = ingestion.substance?.getDuration(for: ingestion.administrationRouteUnwrapped) else {
                return nil
            }
            let offset = graphStartTime.distance(to: ingestion.timeUnwrapped)
            let total = graphStartTime.distance(to: graphEndTime)
            guard let normalizedPoints = NormalizedAroundShape(
                verticalWeight: ingestionLineModel.verticalWeight,
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
            guard let peakMin = durations.peak?.minSec else {return nil}
            guard let peakMax = durations.peak?.maxSec else {return nil}
            guard let offsetMin = durations.offset?.minSec else {return nil}
            guard let offsetMax = durations.offset?.maxSec else {return nil}
            self.bottomLeft = DataPoint(
                xValue: (ingestionTimeOffset
                         + onsetMin
                         + comeupMin
                         + peakMin
                         + offsetMin).ratio(to: totalGraphDuration),
                yValue: minY)
            self.bottomRight = DataPoint(
                xValue: (ingestionTimeOffset
                         + onsetMax
                         + comeupMax
                         + peakMax
                         + offsetMax).ratio(to: totalGraphDuration),
                yValue: minY)
            self.topRight = DataPoint(
                xValue: (ingestionTimeOffset
                         + onsetMax
                         + comeupMax
                         + peakMax).ratio(to: totalGraphDuration),
                yValue: maxY)
            self.topLeft = DataPoint(
                xValue: (ingestionTimeOffset
                         + onsetMin
                         + comeupMin
                         + peakMin).ratio(to: totalGraphDuration),
                yValue: maxY)
        }
    }
}
