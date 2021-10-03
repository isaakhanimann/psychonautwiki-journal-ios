import SwiftUI

struct IngestionTimeLineView: View {

    let startTime: Date
    let endTime: Date
    let isComplication: Bool
    let lineModels: [IngestionLineModel]

    init(sortedIngestions: [Ingestion], isComplication: Bool = false) {
        self.startTime = sortedIngestions.first?.timeUnwrapped ?? Date()
        self.endTime = Experience.getEndTime(for: sortedIngestions) ?? Date().addingTimeInterval(5*60*60)
        self.isComplication = isComplication
        self.lineModels = HelperMethods.getLineModels(sortedIngestions: sortedIngestions)
    }

    var body: some View {
        GeometryReader { geoOut in
            VStack {
                GeometryReader { geoIn in
                    ZStack(alignment: .bottom) {
                        ForEach(0..<lineModels.count, id: \.self) { index in
                            LineView(ingestionLineModel: lineModels[index])
                        }
                        .frame(width: geoOut.size.width, height: geoIn.size.height)

                        if !isComplication {
                            CurrentTimeView(
                                startTime: startTime,
                                endTime: endTime
                            )
                                .frame(width: geoOut.size.width, height: geoIn.size.height)
                        }
                    }
                }
                TimeLabels(
                    startTime: startTime,
                    endTime: endTime,
                    totalWidth: geoOut.size.width,
                    timeStepInSec: isComplication ? 2*60*60 : 60*60
                )
                    .position(x: 0, y: 0)
                    .frame(width: geoOut.size.width)
                    .padding(.top, isComplication ? 2 : 5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TimeLineContent_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        IngestionTimeLineView(sortedIngestions: helper.experiences.first!.sortedIngestionsUnwrapped)
            .frame(height: 300)
    }
}
