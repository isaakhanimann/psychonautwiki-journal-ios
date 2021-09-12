import SwiftUI
import ClockKit

struct ComplicationView: View {

    let ingestions: [Ingestion]
    let timeToDisplay: Date

    var body: some View {
        WatchFaceView(
            ingestions: ingestions,
            clockHandStyle: .justHour,
            timeStyle: .providedTime(time: timeToDisplay)
        )
    }
}

struct ComplicationView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        Group {
            CLKComplicationTemplateGraphicExtraLargeCircularView(
                ComplicationView(
                    ingestions: helper.experiences.first!.sortedIngestionsUnwrapped,
                    timeToDisplay: Date()
                )
            ).previewContext()
        }
    }
}
