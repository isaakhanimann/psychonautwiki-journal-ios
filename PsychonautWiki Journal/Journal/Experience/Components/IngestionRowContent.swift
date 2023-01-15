// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI


struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion
    let roaDose: RoaDose?
    let isTimeRelative: Bool
    let isEyeOpen: Bool

    var body: some View {
        IngestionRowContent(
            numDots: roaDose?.getNumDots(
                ingestionDose: ingestion.doseUnwrapped,
                ingestionUnits: ingestion.unitsUnwrapped
            ),
            substanceColor: ingestion.substanceColor,
            substanceName: ingestion.substanceNameUnwrapped,
            dose: ingestion.doseUnwrapped,
            units: ingestion.unitsUnwrapped,
            isEstimate: ingestion.isEstimate,
            administrationRoute: ingestion.administrationRouteUnwrapped,
            ingestionTime: ingestion.timeUnwrapped,
            note: ingestion.noteUnwrapped,
            isTimeRelative: isTimeRelative,
            isEyeOpen: isEyeOpen
        )
    }
}


struct IngestionRowContent: View {

    let numDots: Int?
    let substanceColor: SubstanceColor
    let substanceName: String
    let dose: Double?
    let units: String
    let isEstimate: Bool
    let administrationRoute: AdministrationRoute
    let ingestionTime: Date
    let note: String
    let isTimeRelative: Bool
    let isEyeOpen: Bool

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "circle.fill")
                .font(.title2)
                .foregroundColor(substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                Text(substanceName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Group {
                    if isTimeRelative {
                        Text(ingestionTime, style: .relative) + Text(" ago")
                    } else {
                        Text(ingestionTime, style: .time)
                    }
                }.foregroundColor(.secondary)
                if !note.isEmpty {
                    Text(note)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                if isEyeOpen {
                    Text(administrationRoute.rawValue.localizedCapitalized).font(.caption)
                }
                if let doseUnwrapped = dose {
                    Text((isEstimate ? "~": "") + doseUnwrapped.formatted() + " " + units).multilineTextAlignment(.trailing)
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
        List {
            Section {
                IngestionRowContent(
                    numDots: 1,
                    substanceColor: .pink,
                    substanceName: "MDMA",
                    dose: 50,
                    units: "mg",
                    isEstimate: true,
                    administrationRoute: .oral,
                    ingestionTime: Date(),
                    note: "",
                    isTimeRelative: false,
                    isEyeOpen: true
                )
                IngestionRowContent(
                    numDots: 2,
                    substanceColor: .blue,
                    substanceName: "Cocaine",
                    dose: 30,
                    units: "mg",
                    isEstimate: true,
                    administrationRoute: .insufflated,
                    ingestionTime: Date(),
                    note: "This is a longer note that might not fit on one line and it needs to be able to handle this",
                    isTimeRelative: true,
                    isEyeOpen: true
                )
                IngestionRowContent(
                    numDots: 2,
                    substanceColor: .green,
                    substanceName: "Cannabis",
                    dose: 10.4,
                    units: "mg (THC)",
                    isEstimate: true,
                    administrationRoute: .smoked,
                    ingestionTime: Date(),
                    note: "This is a longer note that might not fit on one line and it needs to be able to handle this",
                    isTimeRelative: false,
                    isEyeOpen: true
                )
            }
        }
    }
}
