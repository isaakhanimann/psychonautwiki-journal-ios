import SwiftUI
import ClockKit

struct RectangularComplicationView: View {

    let sortedIngestions: [Ingestion]

    var body: some View {
        IngestionTimeLineView(sortedIngestions: sortedIngestions, isComplication: true)
    }
}

struct RectangularComplicationView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper()
        CLKComplicationTemplateGraphicRectangularFullView(
            RectangularComplicationView(
                sortedIngestions: helper.experiences.first!.sortedIngestionsUnwrapped
            )
        ).previewContext()
    }
}
