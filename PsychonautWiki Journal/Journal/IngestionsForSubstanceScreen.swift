//
//  SubstanceIngestionScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 02.01.23.
//

import SwiftUI

struct IngestionsForSubstanceScreen: View {

    @FetchRequest var fetchRequest: FetchedResults<Ingestion>
    let substanceName: String
    let substance: Substance?
    let isTimeRelative = false

    init(substanceName: String) {
        self.substanceName = substanceName
        self.substance = SubstanceRepo.shared.getSubstance(name: substanceName)
        _fetchRequest = FetchRequest<Ingestion>(
            sortDescriptors: [SortDescriptor(\.time, order: .reverse)],
            predicate: NSPredicate(format: "substanceName == %@", substanceName)
        )
    }

    var body: some View {
        List(fetchRequest, id: \.self) { ingestion in
            let roaDose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
            StatsIngestionRow(
                numDots: roaDose?.getNumDots(ingestionDose: ingestion.doseUnwrapped, ingestionUnits: ingestion.unitsUnwrapped),
                substanceName: ingestion.substanceNameUnwrapped,
                dose: ingestion.doseUnwrapped,
                units: ingestion.unitsUnwrapped,
                isEstimate: ingestion.isEstimate,
                administrationRoute: ingestion.administrationRouteUnwrapped,
                ingestionTime: ingestion.timeUnwrapped,
                note: ingestion.noteUnwrapped,
                isTimeRelative: isTimeRelative
            )
        }.navigationTitle(substanceName)
    }
}

struct StatsIngestionRow: View {

    let numDots: Int?
    let substanceName: String
    let dose: Double?
    let units: String
    let isEstimate: Bool
    let administrationRoute: AdministrationRoute
    let ingestionTime: Date
    let note: String
    let isTimeRelative: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    if isTimeRelative {
                        Text(ingestionTime, style: .relative) + Text(" ago")
                    } else {
                        VStack(alignment: .leading) {
                            Text(ingestionTime, style: .date)
                            Text(ingestionTime, style: .time)
                        }
                        .font(.headline)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(administrationRoute.rawValue.localizedCapitalized).font(.caption)
                    if let doseUnwrapped = dose {
                        Text((isEstimate ? "~": "") + doseUnwrapped.formatted() + " " + units)
                    } else {
                        Text("Unknown Dose")
                    }
                    if let numDotsUnwrap = numDots {
                        Spacer().frame(height: 2)
                        DotRows(numDots: numDotsUnwrap)
                        Spacer().frame(height: 2)
                    }
                }.font(.headline)
            }
            if !note.isEmpty {
                Text(note)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct StatsIngestionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StatsIngestionRow(
                numDots: 1,
                substanceName: "MDMA",
                dose: 50,
                units: "mg",
                isEstimate: true,
                administrationRoute: .oral,
                ingestionTime: Date(),
                note: "",
                isTimeRelative: false
            )
            StatsIngestionRow(
                numDots: 2,
                substanceName: "Cocaine",
                dose: 30,
                units: "mg",
                isEstimate: true,
                administrationRoute: .insufflated,
                ingestionTime: Date(),
                note: "This is a longer note that might not fit on one line and it needs to be able to handle this",
                isTimeRelative: false
            )
            StatsIngestionRow(
                numDots: 2,
                substanceName: "Cannabis",
                dose: 30,
                units: "mg (THC)",
                isEstimate: true,
                administrationRoute: .smoked,
                ingestionTime: Date(),
                note: "This is a longer note that might not fit on one line and it needs to be able to handle this",
                isTimeRelative: false
            )
        }
    }
}
