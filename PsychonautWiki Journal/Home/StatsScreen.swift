import SwiftUI

struct StatsScreen: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    var body: some View {
        List {
            Section {
                EffectTimeline(
                    timelineModel: TimelineModel(
                        everythingForEachLine: [
                            // onset comeup peak total
                            EverythingForOneLine(
                                roaDuration: RoaDuration(
                                    onset: DurationRange(min: 30, max: 60, units: .minutes),
                                    comeup: DurationRange(min: 1, max: 2, units: .hours),
                                    peak: DurationRange(min: 1, max: 2, units: .hours),
                                    offset: nil,
                                    total: DurationRange(min: 6, max: 8, units: .hours),
                                    afterglow: nil
                                ),
                                startTime: Date().addingTimeInterval(-60*60),
                                horizontalWeight: 0.5,
                                verticalWeight: 0.5,
                                color: .green
                            ),

                        ]
                    )
                )
            }
        }
        .navigationTitle("Statistics")
    }
}

struct StatsTab_Previews: PreviewProvider {
    static var previews: some View {
        StatsScreen()
    }
}
