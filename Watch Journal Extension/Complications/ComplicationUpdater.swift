import ClockKit

enum ComplicationUpdater {

    static func updateActiveComplications() {
       let complicationServer = CLKComplicationServer.sharedInstance()
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
               complicationServer.reloadTimeline(for: complication)
            }
        }
    }
}
