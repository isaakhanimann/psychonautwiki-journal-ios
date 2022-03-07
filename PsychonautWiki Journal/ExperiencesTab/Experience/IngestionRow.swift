import SwiftUI

struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion

    var body: some View {
        NavigationLink(destination: EditIngestionView(ingestion: ingestion)) {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.title2)
                    .foregroundColor(ingestion.swiftUIColorUnwrapped)
                VStack(alignment: .leading) {
                    Text(ingestion.substanceNameUnwrapped)
                        .font(.title3)
                        .foregroundColor(.primary)
                    Text("\(ingestion.doseInfoString) \(ingestion.administrationRouteUnwrapped.rawValue)")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(ingestion.timeUnwrappedAsString)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct IngestionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngestionRow(ingestion: PreviewHelper.shared.experiences.first!.sortedIngestionsUnwrapped.first!)
        }
        .accentColor(Color.blue)
    }
}
