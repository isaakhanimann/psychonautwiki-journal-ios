import SwiftUI

struct LineView: View {
    let ingestionWithTimelineContext: IngestionWithTimelineContext
    @ObservedObject var ingestion: Ingestion
    let lineWidth: CGFloat = 4

    var body: some View {
        if let roaDurationUnwrapped = ingestion.substance?.getDuration(for: ingestion.administrationRouteUnwrapped) {
            ZStack {
                AroundShapeUp(
                    ingestionWithTimelineContext: ingestionWithTimelineContext,
                    lineWidth: lineWidth,
                    roaDuration: roaDurationUnwrapped,
                    ingestionTime: ingestion.timeUnwrapped
                )
                .fill(ingestion.swiftUIColorUnwrapped.opacity(0.2))
                AroundShapeDown(
                    ingestionWithTimelineContext: ingestionWithTimelineContext,
                    lineWidth: lineWidth,
                    roaDuration: roaDurationUnwrapped,
                    ingestionTime: ingestion.timeUnwrapped
                )
                .fill(ingestion.swiftUIColorUnwrapped.opacity(0.2))
                LineShape(
                    ingestionWithTimelineContext: ingestionWithTimelineContext,
                    lineWidth: lineWidth,
                    roaDuration: roaDurationUnwrapped,
                    ingestionTime: ingestion.timeUnwrapped,
                    horizontalWeight: ingestion.horizontalWeight
                )
                .stroke(
                    ingestion.swiftUIColorUnwrapped,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            }
        }
    }
}
