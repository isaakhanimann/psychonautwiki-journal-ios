import SwiftUI


struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion
    let roaDose: RoaDose?

    var body: some View {
        IngestionRowContent(
            roaDose: roaDose,
            substanceColor: ingestion.substanceColor,
            substanceName: ingestion.substanceNameUnwrapped,
            dose: ingestion.doseUnwrapped,
            units: ingestion.unitsUnwrapped,
            isEstimate: ingestion.isEstimate,
            administrationRoute: ingestion.administrationRouteUnwrapped,
            ingestionTime: ingestion.timeUnwrapped,
            note: ingestion.noteUnwrapped
        )
    }
}


struct IngestionRowContent: View {

    let roaDose: RoaDose?
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
                DotRows(numDots: 5)
                if !note.isEmpty {
                    Text(note)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct DotRows: View {

    let numDots: Int

    var body: some View {
        VStack(spacing: 0) {
            if (numDots==0) {
                HStack(spacing: 0) {
                    ForEach((1...4), id: \.self) {_ in
                        Dot(isFull: false)
                    }
                }
            } else {
                let numFullRows = numDots/4
                let dotsInLastRow = numDots % 4
                if (numFullRows > 0) {
                    ForEach((1...numFullRows), id: \.self) {_ in
                        HStack(spacing: 0) {
                            ForEach(1...4, id: \.self) {_ in
                                Dot(isFull: true)
                            }
                        }
                    }
                }
                if (dotsInLastRow > 0) {
                    HStack(spacing: 0) {
                        ForEach((1...dotsInLastRow), id: \.self) {_ in
                            Dot(isFull: true)
                        }
                        let numEmpty = 4 - dotsInLastRow
                        ForEach((1...numEmpty), id: \.self) {_ in
                            Dot(isFull: false)
                        }
                    }
                }
            }
        }
    }
}

struct Dot: View {
    let isFull: Bool
    var body: some View {
        Image(systemName: isFull ? "circle.fill" : "circle")
            .font(.footnote)
    }
}

struct IngestionRowContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            IngestionRowContent(
                roaDose: SubstanceRepo.shared.getSubstance(name: "MDMA")?.getDose(for: .oral),
                substanceColor: .pink,
                substanceName: "MDMA",
                dose: 50,
                units: "mg",
                isEstimate: true,
                administrationRoute: .oral,
                ingestionTime: Date(),
                note: ""
            )
            IngestionRowContent(
                roaDose: SubstanceRepo.shared.getSubstance(name: "Cocaine")?.getDose(for: .insufflated),
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
        .previewLayout(.sizeThatFits)
    }
}

