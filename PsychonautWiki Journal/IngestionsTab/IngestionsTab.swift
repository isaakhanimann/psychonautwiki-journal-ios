import SwiftUI

struct IngestionsTab: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    var body: some View {
        NavigationView {
            List {
                ForEach(ingestions) { ing in
                    IngestionRow(ingestion: ing)
                }
            }
            .navigationTitle("Ingestions")
        }
    }
}

struct IngestionsTab_Previews: PreviewProvider {
    static var previews: some View {
        IngestionsTab()
    }
}
