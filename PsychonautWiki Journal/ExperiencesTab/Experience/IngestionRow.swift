import SwiftUI

struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.title2)
                .foregroundColor(ingestion.substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                Text(ingestion.substanceNameUnwrapped)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(ingestion.doseInfoString) \(ingestion.administrationRouteUnwrapped.rawValue)")
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(ingestion.timeUnwrapped, style: .time)
        }
    }
}
