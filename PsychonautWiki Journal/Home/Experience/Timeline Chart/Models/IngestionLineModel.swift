import SwiftUI

struct IngestionLineModel {

    let aroundShapeModel: AroundShapeModel
    let lineModel: LineModel
    let color: Color

    init(
        color: Color,
        ingestionTimeOffset: TimeInterval,
        totalGraphDuration: TimeInterval,
        verticalWeight: Double,
        horizontalWeight: Double,
        durations: DurationTypes
    ) {
        self.color = color
        let normalizedXValuesForAroundShapeModel = AroundShapeModel.NormalizedDataPoints(
            verticalWeight: CGFloat(verticalWeight),
            durations: durations,
            ingestionTimeOffset: ingestionTimeOffset,
            totalGraphDuration: totalGraphDuration
        )
        self.aroundShapeModel = AroundShapeModel(normalizedXValuesForModel: normalizedXValuesForAroundShapeModel)

        let normalizedXValuesForLineModel = LineModel.NormalizedDataPoints(
            horizontalWeight: horizontalWeight,
            verticalWeight: CGFloat(verticalWeight),
            durations: durations,
            ingestionTimeOffset: ingestionTimeOffset,
            totalGraphDuration: totalGraphDuration
        )
        self.lineModel = LineModel(normalizedXValuesForModel: normalizedXValuesForLineModel)
    }

    static func getNormalizedValue(of value: TimeInterval, comparedTo maxValue: TimeInterval) -> CGFloat {
        CGFloat(value) / CGFloat(maxValue)
    }
}
