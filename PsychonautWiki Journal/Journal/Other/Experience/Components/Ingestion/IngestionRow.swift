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
        rowContent.alignmentGuide(.listRowSeparatorLeading) { dimension in
            dimension[.leading]
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

    private var routeTextWithSpace: Text {
        let routeText = isEyeOpen ? ingestion.administrationRouteUnwrapped.rawValue : ""
        return Text(" " + routeText).foregroundColor(.secondary)
    }

    private var doseRow: some View {
        HStack {
            VStack(alignment: .leading) {
                let routeText = isEyeOpen ? ingestion.administrationRouteUnwrapped.rawValue : ""
                if let customUnit = ingestion.customUnit { // custom unit
                    if let customUnitDose = ingestion.customUnitDoseUnwrapped { // ingestion custom unit dose known
                        if let calculatedDose = ingestion.calculatedDose { // ingestion calculated dose known
                            if ingestion.isEstimate { // ingestion estimate
                                if let estimatedDoseVariance = ingestion.estimatedDoseVarianceUnwrapped { // ingestion estimated quantitatively
                                    // 3±0.5 lines
                                    let ingestionDoseLine = "\(customUnitDose.formatted())±\(estimatedDoseVariance.roundedToAtMost1Decimal.formatted()) \(3.justUnit(unit: customUnit.unitUnwrapped))"
                                    if let calculatedDoseVariance = ingestion.calculatedDoseVariance { // custom unit variance
                                        // 3±0.5 lines = 60±20mg insufflated
                                        Text(ingestionDoseLine)
                                        Text("= \(calculatedDose.roundedToAtMost1Decimal.formatted())±\(calculatedDoseVariance.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                                    } else { // dose per unit unknown
                                        // 3±0.5 lines insufflated
                                        Text(ingestionDoseLine)
                                        Text("= \(routeText)").foregroundColor(.secondary)
                                    }
                                } else { // ingestion dose estimated non quantitatively
                                    // ~2 pills
                                    let ingestionDoseLine = "~\(customUnitDose.with(unit: customUnit.unitUnwrapped))"
                                    if customUnit.isEstimate {
                                        if let calculatedDoseVariance = ingestion.calculatedDoseVariance {
                                            // ~2 pills = ~40±10 mg oral
                                            Text(ingestionDoseLine)
                                            Text("= ~\(calculatedDose.roundedToAtMost1Decimal.formatted())±\(calculatedDoseVariance.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                                        } else {
                                            // ~2 pills = ~40 mg oral
                                            Text(ingestionDoseLine)
                                            Text("= ~\(calculatedDose.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                                        }
                                    } else {
                                        // ~2 pills = 40 mg oral
                                        Text(ingestionDoseLine)
                                        Text("= ~\(calculatedDose.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                                    }
                                }
                            } else { // ingestion dose not estimated
                                // 2 pills
                                let ingestionDoseLine = customUnitDose.with(unit: customUnit.unitUnwrapped)
                                if customUnit.isEstimate {
                                    if let calculatedDoseVariance = ingestion.calculatedDoseVariance {
                                        // 2 pills = 40±10 mg oral
                                        Text(ingestionDoseLine)
                                        Text("= \(calculatedDose.roundedToAtMost1Decimal.formatted())±\(calculatedDoseVariance.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                                    } else {
                                        // 2 pills = ~40 mg oral
                                        Text(ingestionDoseLine)
                                        Text("= ~\(calculatedDose.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                                    }
                                } else {
                                    // 2 pills = 40 mg oral
                                    Text(ingestionDoseLine)
                                    Text("= \(calculatedDose.roundedToAtMost1Decimal.formatted()) \(customUnit.originalUnitUnwrapped) \(routeText)").foregroundColor(.secondary)
                                }
                            }
                        } else { // ingestion calculated dose not known
                            // 2 pills oral
                            let doseText = customUnitDose.with(unit: customUnit.unitUnwrapped)
                            if ingestion.isEstimate {
                                // ~2 pills oral
                                Text("~" + doseText) + routeTextWithSpace
                            } else {
                                // 2 pills oral
                                Text(doseText) + routeTextWithSpace
                            }
                        }
                    } else { // custom unit dose unknown
                        // Insufflated
                        Text(routeText.localizedCapitalized)
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
