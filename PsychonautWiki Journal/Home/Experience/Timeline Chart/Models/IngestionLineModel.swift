import SwiftUI

struct IngestionLineModel {

    let aroundShapeModelUp: AroundShapeModelUp
    let aroundShapeModelDown: AroundShapeModelDown
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
        let normalizedXValuesForAroundShapeModelUp = AroundShapeModelUp.NormalizedDataPoints(
            verticalWeight: CGFloat(verticalWeight),
            durations: durations,
            ingestionTimeOffset: ingestionTimeOffset,
            totalGraphDuration: totalGraphDuration
        )
        self.aroundShapeModelUp = AroundShapeModelUp(normalizedXValuesForModel: normalizedXValuesForAroundShapeModelUp)

        let normalizedXValuesForAroundShapeModelDown = AroundShapeModelDown.NormalizedDataPoints(
            verticalWeight: CGFloat(verticalWeight),
            durations: durations,
            ingestionTimeOffset: ingestionTimeOffset,
            totalGraphDuration: totalGraphDuration
        )
        self.aroundShapeModelDown = AroundShapeModelDown(
            normalizedXValuesForModel: normalizedXValuesForAroundShapeModelDown
        )

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
