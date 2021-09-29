import SwiftUI

struct LineView: View {
    let ingestionLineModel: IngestionLineModel
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            AroundShape(
                aroundShapeModel: ingestionLineModel.aroundShapeModelUp,
                insetTimes: ingestionLineModel.insetTimes,
                lineWidth: lineWidth
            )
            .fill(ingestionLineModel.color.opacity(0.2))
            AroundShape(
                aroundShapeModel: ingestionLineModel.aroundShapeModelDown,
                insetTimes: ingestionLineModel.insetTimes,
                lineWidth: lineWidth
            )
            .fill(ingestionLineModel.color.opacity(0.2))
            LineShape(
                lineModel: ingestionLineModel.lineModel,
                lineWidth: lineWidth,
                insetTimes: ingestionLineModel.insetTimes
            )
            .stroke(ingestionLineModel.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }
}
