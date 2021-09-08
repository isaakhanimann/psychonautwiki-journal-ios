import SwiftUI

struct OneIngestionView: View {

    let angleModel: AngleModel
    let lineWidth: CGFloat
    let insetPerSide: CGFloat

    let fixGapAngle = Angle(degrees: 1)

    var body: some View {
        ZStack {
            ArcSection(
                startAngle: angleModel.onsetStart,
                endAngle: angleModel.peakStart,
                startColor: .clear,
                endColor: angleModel.color,
                lineWidth: lineWidth,
                insetOneSide: insetPerSide
            )
            ArcSection(
                startAngle: angleModel.peakStart - fixGapAngle,
                endAngle: angleModel.peakEnd,
                startColor: angleModel.color,
                endColor: angleModel.color,
                lineWidth: lineWidth,
                insetOneSide: insetPerSide
            )
            ArcSection(
                startAngle: angleModel.peakEnd - fixGapAngle,
                endAngle: angleModel.offsetEnd,
                startColor: angleModel.color,
                endColor: .clear,
                lineWidth: lineWidth,
                insetOneSide: insetPerSide
            )
        }
    }
}

struct OneIngestionView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        OneIngestionView(
            angleModel: AngleModel(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!),
            lineWidth: 20,
            insetPerSide: 10
        )
    }
}
