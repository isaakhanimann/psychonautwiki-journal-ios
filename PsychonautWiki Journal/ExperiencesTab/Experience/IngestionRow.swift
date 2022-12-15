import SwiftUI

struct IngestionRow: View {

    let substanceColor: SubstanceColor
    let substanceName: String
    let dose: Double?
    let units: String
    let isEstimate: Bool
    let administrationRoute: AdministrationRoute
    let ingestionTime: Date
    let note: String

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.title2)
                .foregroundColor(substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                HStack {
                    Text(substanceName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(ingestionTime, style: .time)
                }
                HStack {
                    Text(administrationRoute.rawValue.localizedCapitalized)
                        .foregroundColor(.secondary)
                    Spacer()
                    if let doseUnwrapped = dose {
                        Text((isEstimate ? "~": "") + doseUnwrapped.formatted() + " " + units)
                    } else {
                        Text("Unknown Dose")
                    }
                }
                if !note.isEmpty {
                    Text(note)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct IngestionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngestionRow(
                substanceColor: .pink,
                substanceName: "MDMA",
                dose: 50,
                units: "mg",
                isEstimate: true,
                administrationRoute: .oral,
                ingestionTime: Date(),
                note: ""
            )
            IngestionRow(
                substanceColor: .blue,
                substanceName: "Cocaine",
                dose: 30,
                units: "mg",
                isEstimate: true,
                administrationRoute: .insufflated,
                ingestionTime: Date(),
                note: "This is a longer note that might not fit on one line and it needs to be able to handle this"
            )
        }
    }
}

