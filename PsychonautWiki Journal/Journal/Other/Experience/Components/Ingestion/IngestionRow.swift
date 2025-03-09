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

struct IngestionRow<Content: View>: View {
    @ObservedObject var ingestion: Ingestion
    let isEyeOpen: Bool
    let isHidingDosageDots: Bool
    @ViewBuilder let timeText: Content

    var body: some View {
        IngestionRowContent(
            ingestion: ingestion,
            substanceColor: ingestion.substanceColor,
            isEyeOpen: isEyeOpen,
            isHidingDosageDots: isHidingDosageDots,
            timeText: {timeText}
        ).foregroundColor(.primary) // to override the button styles
    }
}

private struct IngestionRowContent<Content: View>: View {
    @ObservedObject var ingestion: Ingestion
    let substanceColor: SubstanceColor
    let isEyeOpen: Bool
    let isHidingDosageDots: Bool
    @ViewBuilder let timeText: Content

    var body: some View {
        rowContent.alignmentGuide(.listRowSeparatorLeading) { dimension in
            dimension[.leading]
        }
    }

    private var title: String {
        if let customUnit = ingestion.customUnit {
            "\(ingestion.substanceNameUnwrapped), \(customUnit.nameUnwrapped)"
        } else {
            ingestion.substanceNameUnwrapped
        }
    }

    var rowContent: some View {
        HStack {
            ColorRectangle(color: substanceColor.swiftUIColor)
            VStack(alignment: .leading) {
                timeText.font(.caption)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                doseRow
                Group {
                    if !ingestion.noteUnwrapped.isEmpty {
                        Text(ingestion.noteUnwrapped)
                    }
                    if let stomachFullness = ingestion.stomachFullnessUnwrapped, ingestion.administrationRouteUnwrapped == .oral, stomachFullness != .empty {
                        Text("\(stomachFullness.text) Stomach: ~\(stomachFullness.onsetDelayForOralInHours.asRoundedReadableString) hours delay")
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
                        Text(customUnitDose.doseDescription) + Text(" = \(calculatedDoseDescription)").foregroundColor(.secondary) + routeTextWithSpace
                    } else {
                        Text(customUnitDose.doseDescription) + Text(" = unknown dose").foregroundColor(.secondary) + routeTextWithSpace
                    }
                } else { // not custom unit
                    if let doseUnwrapped = ingestion.doseUnwrapped {
                        if ingestion.isEstimate {
                            if let estimatedDoseStandardDeviation = ingestion.estimatedDoseStandardDeviationUnwrapped {
                                // 20±5 mg insufflated
                                Text("\(doseUnwrapped.formatted())±\(estimatedDoseStandardDeviation.formatted()) \(ingestion.unitsUnwrapped)") + routeTextWithSpace
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
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
            IngestionRowContent(
                ingestion: Ingestion.estimatedDosePreviewSample,
                substanceColor: .blue,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
            IngestionRowContent(
                ingestion: Ingestion.unknownDosePreviewSample,
                substanceColor: .blue,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }            )
            IngestionRowContent(
                ingestion: Ingestion.notePreviewSample,
                substanceColor: .blue,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
            IngestionRowContent(
                ingestion: Ingestion.customSubstancePreviewSample,
                substanceColor: .purple,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }            )
            IngestionRowContent(
                ingestion: Ingestion.customUnitPreviewSample,
                substanceColor: .orange,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
            IngestionRowContent(
                ingestion: Ingestion.customUnitUnknownDosePreviewSample,
                substanceColor: .orange,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
            IngestionRowContent(
                ingestion: Ingestion.estimatedCustomUnitPreviewSample,
                substanceColor: .orange,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
            IngestionRowContent(
                ingestion: Ingestion.estimatedQuantitativelyCustomUnitPreviewSample,
                substanceColor: .orange,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
            IngestionRowContent(
                ingestion: Ingestion.everythingEstimatedQuantitativelyPreviewSample,
                substanceColor: .orange,
                isEyeOpen: true,
                isHidingDosageDots: false,
                timeText: {
                    Text("Sat 13:44")
                }
            )
        }
    }
}
