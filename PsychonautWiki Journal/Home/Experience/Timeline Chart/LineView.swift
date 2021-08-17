import SwiftUI

struct LineView: View {
    let ingestionLineModel: IngestionLineModel
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            AroundShape(aroundShapeModel: ingestionLineModel.aroundShapeModel)
                .fill(ingestionLineModel.color.opacity(0.2))
            LineShape(lineModel: ingestionLineModel.lineModel, lineWidth: lineWidth)
                .stroke(ingestionLineModel.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }
}
