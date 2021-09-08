import SwiftUI

struct OneIngestionView: View {

    let angleModel: AngleModel
    let lineWidth: CGFloat

    let fixGapAngle = Angle(degrees: 1)

    var body: some View {
        ZStack {
            ArcSection(
                startAngle: angleModel.onsetStart,
                endAngle: angleModel.peakStart + fixGapAngle,
                startColor: .clear,
                endColor: angleModel.color,
                lineWidth: lineWidth
            )
            ArcSection(
                startAngle: angleModel.peakStart,
                endAngle: angleModel.peakEnd,
                startColor: angleModel.color,
                endColor: angleModel.color,
                lineWidth: lineWidth
            )
            ArcSection(
                startAngle: angleModel.peakEnd - fixGapAngle,
                endAngle: angleModel.offsetEnd,
                startColor: angleModel.color,
                endColor: .clear,
                lineWidth: lineWidth
            )
            IngestionPoint(
                angle: angleModel.ingestionPoint,
                circleSize: lineWidth/3,
                color: angleModel.color
            )
        }
    }
}

struct OneIngestionView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height)
            OneIngestionView(
                angleModel: AngleModel(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!),
                lineWidth: 20
            )
            .frame(width: squareSize, height: squareSize)
            .padding(10)
        }
    }
}
