import SwiftUI

struct OneIngestionView: View {

    let angleModel: AngleModel
    let index: Int
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            ArcShape(
                startAngle: angleModel.peakStart,
                endAngle: angleModel.peakEnd,
                lineWidth: lineWidth,
                insetTimes: index
            )
            .stroke(angleModel.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
        }
    }
}

struct OneIngestionView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        OneIngestionView(
            angleModel: AngleModel(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!),
            index: 0,
            lineWidth: 20
        )
    }
}
