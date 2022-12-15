import SwiftUI

struct StatsTab: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    var body: some View {
        NavigationView {
            List {
                ForEach(ingestions) { ing in
                    IngestionRow(
                        substanceColor: ing.substanceColor,
                        substanceName: ing.substanceNameUnwrapped,
                        dose: ing.doseUnwrapped,
                        units: ing.unitsUnwrapped,
                        isEstimate: ing.isEstimate,
                        administrationRoute: ing.administrationRouteUnwrapped,
                        ingestionTime: ing.timeUnwrapped,
                        note: ing.noteUnwrapped
                    )
                }
            }
            .navigationTitle("Ingestions")
        }
    }
}

struct StatsTab_Previews: PreviewProvider {
    static var previews: some View {
        StatsTab()
    }
}
