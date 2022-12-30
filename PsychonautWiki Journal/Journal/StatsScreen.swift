import SwiftUI
import Charts

@available(iOS 16, *)
struct StatsScreen: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    var body: some View {
        StatsScreenContent()
    }
}

@available(iOS 16, *)
struct StatsScreenContent: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    ExperienceDetails(experienceData: .mock1)
                } label: {
                    ExperienceOverview(experienceData: .mock1)
                }
            }
            Section {
                NavigationLink {
                    IngestionDetails(ingestionData: .mock1)
                } label: {
                    IngestionOverview(ingestionData: .mock1)
                }
            }
        }.navigationTitle("Stats")
    }
}

@available(iOS 16, *)
struct StatsScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatsScreenContent()
        }
    }
}
