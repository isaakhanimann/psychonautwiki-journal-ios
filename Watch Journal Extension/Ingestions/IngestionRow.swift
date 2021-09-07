import SwiftUI

struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion

    var body: some View {
        Group {
            if let substanceUnwrapped = ingestion.substanceCopy {
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.title3)
                        .foregroundColor(ingestion.swiftUIColorUnwrapped)
                    VStack(alignment: .leading) {
                        Text(substanceUnwrapped.nameUnwrapped)
                            .font(.title3)
                            .foregroundColor(.primary)
                        HStack(alignment: .bottom) {
                            Text("\(ingestion.doseInfoString) \(ingestion.administrationRouteUnwrapped.rawValue)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(ingestion.timeUnwrappedAsString)
                                .font(.footnote)
                                .foregroundColor(.primary)
                        }
                    }
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
