import SwiftUI

struct LineView: View {
    let ingestionLineModel: IngestionWithTimelineContext
    let graphStartTime: Date
    let graphEndTime: Date
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            AroundShapeUp(
                ingestionLineModel: ingestionLineModel,
                graphStartTime: graphStartTime,
                graphEndTime: graphEndTime,
                lineWidth: lineWidth
            )
                .fill(ingestionLineModel.ingestion.swiftUIColorUnwrapped.opacity(0.2))
            AroundShapeDown(
                ingestionLineModel: ingestionLineModel,
                graphStartTime: graphStartTime,
                graphEndTime: graphEndTime,
                lineWidth: lineWidth
            )
                .fill(ingestionLineModel.ingestion.swiftUIColorUnwrapped.opacity(0.2))
            LineShape(
                ingestionLineModel: ingestionLineModel,
                graphStartTime: graphStartTime,
                graphEndTime: graphEndTime,
                lineWidth: lineWidth
            )
                .stroke(
                    ingestionLineModel.ingestion.swiftUIColorUnwrapped,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
        }
    }
}
