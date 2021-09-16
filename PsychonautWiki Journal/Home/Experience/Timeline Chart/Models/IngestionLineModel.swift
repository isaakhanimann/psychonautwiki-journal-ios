import SwiftUI

struct IngestionLineModel {

    let aroundShapeModelUp: AroundShapeModelUp
    let aroundShapeModelDown: AroundShapeModelDown
    let lineModel: LineModel
    let insetTimes: Int
    let color: Color

    init?(
        color: Color,
        ingestionTimeOffset: TimeInterval,
        totalGraphDuration: TimeInterval,
        verticalWeight: Double,
        horizontalWeight: Double,
        durations: DurationTypes,
        insetTimes: Int
    ) {
        self.color = color
        guard let normalizedXValuesForAroundShapeModelUp = AroundShapeModelUp.NormalizedDataPoints(
            verticalWeight: CGFloat(verticalWeight),
            durations: durations,
            ingestionTimeOffset: ingestionTimeOffset,
            totalGraphDuration: totalGraphDuration
        ) else {return nil}
        self.aroundShapeModelUp = AroundShapeModelUp(normalizedXValuesForModel: normalizedXValuesForAroundShapeModelUp)

        guard let normalizedXValuesForAroundShapeModelDown = AroundShapeModelDown.NormalizedDataPoints(
            verticalWeight: CGFloat(verticalWeight),
            durations: durations,
            ingestionTimeOffset: ingestionTimeOffset,
            totalGraphDuration: totalGraphDuration
        ) else {return nil}
        self.aroundShapeModelDown = AroundShapeModelDown(
            normalizedXValuesForModel: normalizedXValuesForAroundShapeModelDown
        )

        guard let normalizedXValuesForLineModel = LineModel.NormalizedDataPoints(
            horizontalWeight: horizontalWeight,
            verticalWeight: CGFloat(verticalWeight),
            durations: durations,
            ingestionTimeOffset: ingestionTimeOffset,
            totalGraphDuration: totalGraphDuration
        ) else {return nil}
        self.lineModel = LineModel(normalizedXValuesForModel: normalizedXValuesForLineModel)
        self.insetTimes = insetTimes
    }

    static func getNormalizedValue(of value: TimeInterval, comparedTo maxValue: TimeInterval) -> CGFloat {
        CGFloat(value) / CGFloat(maxValue)
    }
}
