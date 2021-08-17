import SwiftUI

struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion

    var body: some View {
        Group {
            if let substanceUnwrapped = ingestion.substance {
                NavigationLink(destination: EditIngestionView(ingestion: ingestion)) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.title2)
                            .foregroundColor(ingestion.swiftUIColorUnwrapped)
                        Text(substanceUnwrapped.nameUnwrapped)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(ingestion.doseInfoString)
                            .foregroundColor(.secondary)
                        Text(ingestion.timeUnwrappedAsString)
                            .foregroundColor(.primary)
                    }
                }
            }
        }

    }
}
