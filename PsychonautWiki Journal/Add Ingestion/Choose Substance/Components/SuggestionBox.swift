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
import WrappingHStack

struct SuggestionBox: View {
    let suggestion: Suggestion
    let dismiss: () -> Void
    let isEyeOpen: Bool

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                WrappingHStack(
                    alignment: .leading,
                    horizontalSpacing: horizontalSpacing,
                    verticalSpacing: verticalSpacing)
                {
                    ForEach(suggestion.dosesAndUnit) { doseAndUnit in
                        if let doseDescription = doseAndUnit.doseDescription {
                            NavigationLink(
                                doseDescription,
                                value: FinishIngestionScreenArguments(
                                    substanceName: suggestion.substanceName,
                                    administrationRoute: suggestion.route,
                                    dose: doseAndUnit.dose,
                                    units: doseAndUnit.units,
                                    isEstimate: doseAndUnit.isEstimate,
                                    estimatedDoseVariance: doseAndUnit.estimatedDoseVariance))
                                .buttonStyle(.bordered).fixedSize()
                        } else {
                            NavigationLink("Unknown", value: FinishIngestionScreenArguments(
                                substanceName: suggestion.substanceName,
                                administrationRoute: suggestion.route,
                                dose: doseAndUnit.dose,
                                units: doseAndUnit.units,
                                isEstimate: doseAndUnit.isEstimate,
                                estimatedDoseVariance: nil
                            ))
                            .buttonStyle(.bordered).fixedSize()
                        }
                    }
                    if let substance = suggestion.substance, let units = substance.getDose(for: suggestion.route)?.units {
                        NavigationLink(
                            "Enter \(units)",
                            value: SubstanceAndRoute(substance: substance, administrationRoute: suggestion.route))
                            .buttonStyle(.borderedProminent).fixedSize()
                    } else if let units = suggestion.dosesAndUnit.first?.units {
                        NavigationLink("Enter \(units)", value: CustomChooseDoseScreenArguments(
                            substanceName: suggestion.substanceName,
                            units: units,
                            administrationRoute: suggestion.route))
                            .buttonStyle(.borderedProminent).fixedSize()
                    }
                }
                if !suggestion.customUnitDoses.isEmpty {
                    WrappingHStack(
                        alignment: .leading,
                        horizontalSpacing: horizontalSpacing,
                        verticalSpacing: verticalSpacing)
                    {
                        ForEach(suggestion.customUnitDoses) { customUnitDose in
                            NavigationLink(
                                value: FinishIngestionScreenArguments(
                                    substanceName: suggestion.substanceName,
                                    administrationRoute: suggestion.route,
                                    dose: customUnitDose.dose,
                                    units: customUnitDose.customUnit.originalUnitUnwrapped,
                                    isEstimate: customUnitDose.isEstimate,
                                    estimatedDoseVariance: customUnitDose.estimatedDoseVariance,
                                    customUnit: customUnitDose.customUnit))
                            {
                                CustomUnitDoseLabel(customUnitDose: customUnitDose)
                            }.buttonStyle(.bordered).fixedSize()
                        }
                    }
                }
                if !suggestion.customUnits.isEmpty {
                    WrappingHStack(
                        alignment: .leading,
                        horizontalSpacing: horizontalSpacing,
                        verticalSpacing: verticalSpacing)
                    {
                        ForEach(suggestion.customUnits) { customUnit in
                            NavigationLink(value: customUnit) {
                                VStack {
                                    Text(customUnit.nameUnwrapped).font(.caption2)
                                    Text("Enter \(2.justUnit(unit: customUnit.unitUnwrapped))")
                                }
                            }.buttonStyle(.borderedProminent).fixedSize()
                        }
                    }
                }
                Group {
                    Text("Last ingestion ") + Text(suggestion.lastTimeUsed, style: .relative) + Text(" ago")
                }.font(.footnote).foregroundColor(.secondary)
            }
        } label: {
            let route = isEyeOpen ? suggestion.route.rawValue.localizedCapitalized : ""
            Label(
                "\(suggestion.substanceName) \(route)",
                systemImage: "circle.fill")
                .foregroundColor(suggestion.substanceColor.swiftUIColor)
        }
    }

    private let horizontalSpacing: Double = 4
    private let verticalSpacing: Double = 5

}

#Preview {
    NavigationStack {
        LazyVStack {
            SuggestionBox(
                suggestion: Suggestion(
                    substanceName: "MDMA",
                    substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                    route: .insufflated,
                    substanceColor: .pink,
                    dosesAndUnit: [
                        RegularDoseAndUnit(
                            dose: 20,
                            units: "mg",
                            isEstimate: true,
                            estimatedDoseVariance: 2),
                        RegularDoseAndUnit(
                            dose: nil,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseVariance: nil),
                        RegularDoseAndUnit(
                            dose: 30,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseVariance: nil),
                    ],
                    customUnitDoses: [],
                    customUnits: [],
                    lastTimeUsed: Date.now.addingTimeInterval(-2 * 60 * 60)),
                dismiss: { },
                isEyeOpen: true)
            SuggestionBox(
                suggestion: Suggestion(
                    substanceName: "Cannabis",
                    substance: SubstanceRepo.shared.getSubstance(name: "Cannabis"),
                    route: .smoked,
                    substanceColor: .green,
                    dosesAndUnit: [
                        RegularDoseAndUnit(
                            dose: 3,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseVariance: nil),
                        RegularDoseAndUnit(
                            dose: 6,
                            units: "mg",
                            isEstimate: true,
                            estimatedDoseVariance: 1),
                        RegularDoseAndUnit(
                            dose: nil,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseVariance: nil),
                        RegularDoseAndUnit(
                            dose: 2.5,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseVariance: nil),
                    ],
                    customUnitDoses: [],
                    customUnits: [],
                    lastTimeUsed: Date.now.addingTimeInterval(-3 * 60 * 60)),
                dismiss: { },
                isEyeOpen: true)
        }.padding(.horizontal)
    }
}
