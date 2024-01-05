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
            ingestion: ingestion,
            substanceColor: ingestion.substanceColor,
            timeDisplayStyle: timeDisplayStyle,
            isEyeOpen: isEyeOpen,
            isHidingDosageDots: isHidingDosageDots,
            firstIngestionTime: firstIngestionTime
        )
    }
}

private struct IngestionRowContent: View {
    @ObservedObject var ingestion: Ingestion
    let substanceColor: SubstanceColor
    let timeDisplayStyle: TimeDisplayStyle
    let isEyeOpen: Bool
    let isHidingDosageDots: Bool
    let firstIngestionTime: Date?

    var body: some View {
        if #available(iOS 16.0, *) {
            rowContent.alignmentGuide(.listRowSeparatorLeading) { dimension in
                dimension[.leading]
            }
        } else {
            rowContent
        }
    }

    private var substanceNameSuffix: String {
        if let customUnit = ingestion.customUnit {
            " " + customUnit.nameUnwrapped
        } else {
            ""
        }
    }

    var rowContent: some View {
        HStack {
            ColorRectangle(color: substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                HStack {
                    Text(ingestion.substanceNameUnwrapped + substanceNameSuffix)
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Group {
                        if timeDisplayStyle == .relativeToNow {
                            Text(ingestion.timeUnwrapped, style: .relative) + Text(" ago")
                        } else if let firstIngestionTime, timeDisplayStyle == .relativeToStart {
                            Text(DateDifference.formatted(DateDifference.between(firstIngestionTime, and: ingestion.timeUnwrapped)))
                        } else {
                            Text(ingestion.timeUnwrapped, format: Date.FormatStyle().hour().minute().weekday(.abbreviated))
                        }
                    }
                    .font(.subheadline)
                }
                doseRow
                Group {
                    if !ingestion.noteUnwrapped.isEmpty {
                        Text(ingestion.noteUnwrapped)
                    }
                    if let stomachFullness = ingestion.stomachFullnessUnwrapped, ingestion.administrationRouteUnwrapped == .oral {
                        Text("\(stomachFullness.text) Stomach: ~\(stomachFullness.onsetDelayForOralInHours.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 1)) hours delay")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
    }

    private var doseRow: some View {
        HStack {
            let routeText = isEyeOpen ? ingestion.administrationRouteUnwrapped.rawValue : ""
            if let customUnit = ingestion.customUnit {
                if let customUnitDose = ingestion.customUnitDoseUnwrapped {
                    if let calculatedDose = ingestion.calculatedDose {
                        Text("\(ingestion.isEstimate ? "~" : "")\(customUnitDose.formatted()) \(customUnit.unitUnwrapped)") + Text(" = \((ingestion.isEstimate || customUnit.isEstimate) ? "~" : "")\(calculatedDose.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                    } else {
                        Text("\(ingestion.isEstimate ? "~" : "")\(customUnitDose.formatted()) \(customUnit.unitUnwrapped) \(routeText)")
                    }
                } else {
                    Text(routeText.localizedCapitalized)
                }
            } else {
                if let doseUnwrapped = ingestion.doseUnwrapped {
                    Text("\(ingestion.isEstimate ? "~" : "")\(doseUnwrapped.formatted()) \(ingestion.unitsUnwrapped) \(routeText)")
                } else {
                    Text(routeText.localizedCapitalized)
                }
            }
            Spacer()
            if let numDotsUnwrap = ingestion.numberOfDots, !isHidingDosageDots {
                DotRows(numDots: numDotsUnwrap)
            }
        }
        .font(.subheadline)
        .multilineTextAlignment(.trailing)
    }
}

#Preview {
    List {
        Section {
            IngestionRowContent(
                ingestion: Ingestion.knownDosePreviewSample,
                substanceColor: .pink,
                timeDisplayStyle: .relativeToNow,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                ingestion: Ingestion.estimatedDosePreviewSample,
                substanceColor: .blue,
                timeDisplayStyle: .relativeToStart,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                ingestion: Ingestion.unknownDosePreviewSample,
                substanceColor: .blue,
                timeDisplayStyle: .relativeToStart,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                ingestion: Ingestion.notePreviewSample,
                substanceColor: .blue,
                timeDisplayStyle: .relativeToStart,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                ingestion: Ingestion.customSubstancePreviewSample,
                substanceColor: .purple,
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                ingestion: Ingestion.customUnitPreviewSample,
                substanceColor: .orange,
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                ingestion: Ingestion.estimatedCustomUnitPreviewSample,
                substanceColor: .orange,
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
        }
    }
}
