import SwiftUI

struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion

    var body: some View {
        Group {
            if let substanceUnwrapped = ingestion.substanceCopy {
                NavigationLink(destination: EditIngestionView(ingestion: ingestion)) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.title2)
                            .foregroundColor(ingestion.swiftUIColorUnwrapped)
                        VStack(alignment: .leading) {
                            Text(substanceUnwrapped.nameUnwrapped)
                                .font(.title3)
                                .foregroundColor(.primary)
                            Text("\(ingestion.doseInfoString) \(ingestion.administrationRouteUnwrapped.rawValue)")
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(ingestion.timeUnwrappedAsString)
                                .foregroundColor(.primary)
                            if ingestion.endTime > Date() {
                                Text(ingestion.endTime, style: .relative)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}
