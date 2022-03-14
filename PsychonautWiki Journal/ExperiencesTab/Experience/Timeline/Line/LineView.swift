import SwiftUI

struct LineView: View {
    let ingestionWithTimelineContext: IngestionWithTimelineContext
    @ObservedObject var ingestion: Ingestion
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            AroundShapeUp(
                ingestionWithTimelineContext: ingestionWithTimelineContext,
                lineWidth: lineWidth,
                ingestion: ingestion
            )
                .fill(ingestion.swiftUIColorUnwrapped.opacity(0.2))
            AroundShapeDown(
                ingestionWithTimelineContext: ingestionWithTimelineContext,
                lineWidth: lineWidth,
                ingestion: ingestion
            )
                .fill(ingestion.swiftUIColorUnwrapped.opacity(0.2))
            LineShape(
                ingestionWithTimelineContext: ingestionWithTimelineContext,
                lineWidth: lineWidth,
                ingestion: ingestion
            )
                .stroke(
                    ingestion.swiftUIColorUnwrapped,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
        }
    }
}
