import SwiftUI

struct GaugesView: View {

    let ingestions: [Ingestion]

    var body: some View {
        Group {
            if ingestions.isEmpty {
                Text("No ingestions yet")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    VStack(alignment: .center, spacing: 15) {
                        ForEach(ingestions) { ingestion in
                            GaugeRow(ingestion: ingestion)
                        }
                    }
                }
            }
        }
    }
}

struct GaugesView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        GaugesView(ingestions: helper.experiences.first!.sortedIngestionsUnwrapped)
    }
}
