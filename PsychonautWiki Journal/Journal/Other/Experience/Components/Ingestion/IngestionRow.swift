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
        ).foregroundColor(.primary) // to override the button styles
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
        rowContent.alignmentGuide(.listRowSeparatorLeading) { dimension in
            dimension[.leading]
        }
    }

    private var title: String {
        if let customUnit = ingestion.customUnit {
            "\(ingestion.substanceNameUnwrapped) (\(customUnit.nameUnwrapped))"
        } else {
            ingestion.substanceNameUnwrapped
        }
    }

    var rowContent: some View {
        HStack {
            ColorRectangle(color: substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Group {
                        if timeDisplayStyle == .relativeToNow {
                            Text(ingestion.timeUnwrapped, style: .relative) + Text(" ago")
                        } else if let firstIngestionTime, timeDisplayStyle == .relativeToStart {
                            let dateComponents = DateDifference.between(firstIngestionTime, and: ingestion.timeUnwrapped)
                            let isFirstIngestion = dateComponents.day == 0 && dateComponents.hour == 0 && dateComponents.minute == 0 && dateComponents.second == 0
                            if isFirstIngestion {
                                Text("t=") + Text(ingestion.timeUnwrapped, format: Date.FormatStyle().hour().minute().weekday(.abbreviated))
                            } else {
                                Text("t+") + Text(DateDifference.formatted(dateComponents))
                            }
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
                    if let stomachFullness = ingestion.stomachFullnessUnwrapped, ingestion.administrationRouteUnwrapped == .oral, stomachFullness != .empty {
                        Text("\(stomachFullness.text) Stomach: ~\(stomachFullness.onsetDelayForOralInHours.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 1)) hours delay")
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
    }

    private var routeTextWithSpace: Text {
        let routeText = isEyeOpen ? ingestion.administrationRouteUnwrapped.rawValue : ""
        return Text(" " + routeText).foregroundColor(.secondary)
    }

    private var doseRow: some View {
        HStack {
            VStack(alignment: .leading) {
                let routeText = isEyeOpen ? ingestion.administrationRouteUnwrapped.rawValue : ""
                if let customUnitDose = ingestion.customUnitDose {
                    if let calculatedDoseDescription = customUnitDose.calculatedDoseDescription {
                        Text(customUnitDose.doseDescription) + routeTextWithSpace
                        Text("= \(calculatedDoseDescription)").foregroundColor(.secondary)
                    } else {
                        Text(customUnitDose.doseDescription) + Text(" " + routeText).foregroundColor(.secondary)
                    }
                } else { // not custom unit
                    if let doseUnwrapped = ingestion.doseUnwrapped {
                        if ingestion.isEstimate {
                            if let estimatedDoseVariance = ingestion.estimatedDoseVarianceUnwrapped {
                                // 20±5 mg insufflated
                                Text("\(doseUnwrapped.formatted())±\(estimatedDoseVariance.formatted()) \(ingestion.unitsUnwrapped)") + routeTextWithSpace
                            } else {
                                // ~20 mg insufflated
                                Text("~\(doseUnwrapped.formatted()) \(ingestion.unitsUnwrapped)") + routeTextWithSpace
                            }
                        } else {
                            // 20 mg insufflated
                            Text("\(doseUnwrapped.formatted()) \(ingestion.unitsUnwrapped)") + routeTextWithSpace
                        }
                    } else {
                        // Insufflated
                        Text(routeText.localizedCapitalized).foregroundColor(.secondary)
                    }
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
                timeDisplayStyle: .relativeToStart,
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
                ingestion: Ingestion.customUnitUnknownDosePreviewSample,
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
            IngestionRowContent(
                ingestion: Ingestion.estimatedQuantitativelyCustomUnitPreviewSample,
                substanceColor: .orange,
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
            IngestionRowContent(
                ingestion: Ingestion.everythingEstimatedQuantitativelyPreviewSample,
                substanceColor: .orange,
                timeDisplayStyle: .regular,
                isEyeOpen: true,
                isHidingDosageDots: false,
                firstIngestionTime: Date().addingTimeInterval(-60 * 60)
            )
        }
    }
}
