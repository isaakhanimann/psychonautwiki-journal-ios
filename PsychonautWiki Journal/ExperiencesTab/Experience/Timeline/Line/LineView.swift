import SwiftUI

struct LineView: View {
    let ingestionWithTimelineContext: IngestionWithTimelineContext
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            AroundShapeUp(
                ingestionWithTimelineContext: ingestionWithTimelineContext,
                lineWidth: lineWidth
            )
                .fill(ingestionWithTimelineContext.ingestion.swiftUIColorUnwrapped.opacity(0.2))
            AroundShapeDown(
                ingestionWithTimelineContext: ingestionWithTimelineContext,
                lineWidth: lineWidth
            )
                .fill(ingestionWithTimelineContext.ingestion.swiftUIColorUnwrapped.opacity(0.2))
            LineShape(
                ingestionWithTimelineContext: ingestionWithTimelineContext,
                lineWidth: lineWidth
            )
                .stroke(
                    ingestionWithTimelineContext.ingestion.swiftUIColorUnwrapped,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
        }
    }
}
