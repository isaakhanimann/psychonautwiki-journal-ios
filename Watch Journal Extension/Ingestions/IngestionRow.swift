import SwiftUI

struct IngestionRow: View {

    let ingestion: Ingestion

    var body: some View {
        Group {
            if let substanceCopyUnwrapped = ingestion.substanceCopy {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.headline)
                            .foregroundColor(ingestion.swiftUIColorUnwrapped)
                        VStack(alignment: .leading) {
                            Text(substanceCopyUnwrapped.nameUnwrapped).font(.headline)
                            Text("\(ingestion.doseInfoString) \(ingestion.administrationRouteUnwrapped.rawValue)")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                    IngestionGauge(ingestion: ingestion)
                }
            }
        }
    }
}

struct IngestionRow_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        List {
            IngestionRow(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!)
        }
    }
}
