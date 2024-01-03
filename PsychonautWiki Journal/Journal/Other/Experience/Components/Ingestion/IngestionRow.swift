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
    let firstIngestionTime: Date?
    let timeDisplayStyle: TimeDisplayStyle
    let isEyeOpen: Bool
    let isHidingDosageDots: Bool

    var body: some View {
        IngestionRowContent(
            numDots: ingestion.numberOfDots,
            substanceColor: ingestion.substanceColor,
            substanceName: ingestion.substanceNameUnwrapped,
            dose: ingestion.doseUnwrapped,
            units: ingestion.unitsUnwrapped,
            isEstimate: ingestion.isEstimate,
            administrationRoute: ingestion.administrationRouteUnwrapped,
            ingestionTime: ingestion.timeUnwrapped,
            note: ingestion.noteUnwrapped,
            timeDisplayStyle: timeDisplayStyle,
            isEyeOpen: isEyeOpen,
            isHidingDosageDots: isHidingDosageDots,
            stomachFullness: ingestion.stomachFullnessUnwrapped,
            firstIngestionTime: firstIngestionTime
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
    let timeDisplayStyle: TimeDisplayStyle
    let isEyeOpen: Bool
    let isHidingDosageDots: Bool
    let stomachFullness: StomachFullness?
    let firstIngestionTime: Date?

    var body: some View {
        if #available(iOS 16.0, *) {
            rowContent.alignmentGuide(.listRowSeparatorLeading) { d in
                d[.leading]
            }
        } else {
            rowContent
        }
    }

    var rowContent: some View {
        HStack {
            ColorRectangle(color: substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                HStack {
                    Text(substanceName)
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Group {
                        if timeDisplayStyle == .relativeToNow {
                            Text(ingestionTime, style: .relative) + Text(" ago")
                        } else if let firstIngestionTime, timeDisplayStyle == .relativeToStart {
                            Text(DateDifference.formatted(DateDifference.between(firstIngestionTime, and: ingestionTime)))
                        } else {
                            Text(ingestionTime, format: Date.FormatStyle().hour().minute().weekday(.abbreviated))
                        }
                    }
                    .font(.subheadline)
                }
                HStack {
                    let routeText = isEyeOpen ? administrationRoute.rawValue : ""
                    if let doseUnwrapped = dose {
                        Text("\(isEstimate ? "~" : "")\(doseUnwrapped.formatted()) \(units) \(routeText)").multilineTextAlignment(.trailing)
                    } else {
                        Text(routeText.localizedCapitalized)
                    }
                    Spacer()
                    if let numDotsUnwrap = numDots, !isHidingDosageDots {
                        DotRows(numDots: numDotsUnwrap)
                    }
                }
                .font(.subheadline)
                Group {
                    if !note.isEmpty {
                        Text(note)
                    }
                    if let stomachFullness, administrationRoute == .oral {
                        Text("\(stomachFullness.text) Stomach: ~\(stomachFullness.onsetDelayForOralInHours.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 1)) hours delay")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    List {
        Section {
            IngestionRowContent(
                numDots: 4,
                substanceColor: .cyan,
                substanceName: "Methamphetamine",
                dose: 50,
                units: "mg",
                isEstimate: false,
                administrationRoute: .oral,
                ingestionTime: Date(),
                note: "",
                timeDisplayStyle: .relativeToNow,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: .full,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
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
                note: "",
                timeDisplayStyle: .relativeToStart,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: nil,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                numDots: nil,
                substanceColor: .blue,
                substanceName: "Cocaine",
                dose: nil,
                units: "mg",
                isEstimate: true,
                administrationRoute: .insufflated,
                ingestionTime: Date(),
                note: "",
                timeDisplayStyle: .relativeToStart,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: nil,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
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
                timeDisplayStyle: .relativeToStart,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: nil,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                numDots: 2,
                substanceColor: .brown,
                substanceName: "Psilocybin Mushrooms",
                dose: 20,
                units: "mg",
                isEstimate: true,
                administrationRoute: .oral,
                ingestionTime: Date().addingTimeInterval(-4 * 60 * 60 + 330),
                note: "",
                timeDisplayStyle: .relativeToNow,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: nil,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                numDots: 2,
                substanceColor: .green,
                substanceName: "Cannabis",
                dose: 10.4,
                units: "mg",
                isEstimate: true,
                administrationRoute: .smoked,
                ingestionTime: Date(),
                note: "",
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: nil,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                numDots: 1,
                substanceColor: .pink,
                substanceName: "MDMA",
                dose: 50,
                units: "mg",
                isEstimate: false,
                administrationRoute: .oral,
                ingestionTime: Date(),
                note: "This is a longer note that might not fit on one line and it needs to be able to handle this",
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: .full,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                numDots: nil,
                substanceColor: .purple,
                substanceName: "Customsubstance",
                dose: 50,
                units: "mg",
                isEstimate: false,
                administrationRoute: .oral,
                ingestionTime: Date(),
                note: "",
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                stomachFullness: .full,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
        }
    }
}
