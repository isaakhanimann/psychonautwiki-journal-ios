import SwiftUI

struct SubstanceDoseRow: View {

    let substanceDose: Experience.SubstanceWithDose

    var body: some View {
        if let sub = substanceDose.substance {
            NavigationLink {
                SubstanceView(substance: sub)
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading) {
                        Text(substanceDose.substanceName)
                        let unitsText = substanceDose.units ?? ""
                        let doseText = substanceDose.cumulativeDose == 0 ?
                        "Unknown" :
                        "\(substanceDose.cumulativeDose.formatted()) \(unitsText)"
                        Text("Total Dose: \(doseText)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        } else {
            VStack(alignment: .leading) {
                Text(substanceDose.substanceName)
                Text("No info on this substance")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SubstanceDoseRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SubstanceDoseRow(
                substanceDose: Experience.SubstanceWithDose(
                    substanceName: "Caffeine",
                    substance: PreviewHelper.shared.getSubstance(with: "Caffeine"),
                    units: "mg",
                    cumulativeDose: 100
                )
            )
        }
    }
}
