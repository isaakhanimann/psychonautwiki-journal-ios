import SwiftUI
import ClockKit

struct CircularComplicationView: View {

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
                CircularComplicationView(
                    ingestions: helper.experiences.first!.sortedIngestionsUnwrapped,
                    timeToDisplay: Date()
                )
            ).previewContext()

            CLKComplicationTemplateGraphicCircularView(
                CircularComplicationView(
                    ingestions: helper.experiences.first!.sortedIngestionsUnwrapped,
                    timeToDisplay: Date()
                )
            ).previewContext()

            CLKComplicationTemplateGraphicRectangularFullView(
                CircularComplicationView(
                    ingestions: helper.experiences.first!.sortedIngestionsUnwrapped,
                    timeToDisplay: Date()
                )
            ).previewContext()
        }
    }
}
