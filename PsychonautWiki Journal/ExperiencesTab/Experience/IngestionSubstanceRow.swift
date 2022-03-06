import SwiftUI

struct IngestionSubstanceRow: View {

    let ingestion: Ingestion

    var body: some View {
        if let sub = ingestion.substance {
            NavigationLink {
                SubstanceView(substance: sub)
            } label: {
                VStack(alignment: .leading) {
                    Text(ingestion.substanceNameUnwrapped)
                        .font(.title3)
                        .foregroundColor(.primary)
                    if !ingestion.canTimeLineBeDrawn {
                        Text("Timeline not fully defined")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }

        } else {
            VStack(alignment: .leading) {
                Text(ingestion.substanceNameUnwrapped)
                    .font(.title3)
                    .foregroundColor(.primary)
                Text("No info on this substance")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct IngestionSubstanceRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngestionSubstanceRow(ingestion: PreviewHelper.shared.experiences.first!.sortedIngestionsUnwrapped.first!)
        }
    }
}
