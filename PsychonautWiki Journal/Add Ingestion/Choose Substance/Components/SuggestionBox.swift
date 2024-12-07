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
    let navigateToCustomUnitChooseDose: (CustomUnit) -> Void

    @State private var isAddCustomUnitSheetShown = false

    var body: some View {
        VStack(alignment: .leading) {
            let route = isEyeOpen ? suggestion.route.rawValue.localizedCapitalized : ""
            Label(
                "\(suggestion.substanceName) \(route)",
                systemImage: "circle.fill")
            .font(.headline)
            .foregroundColor(suggestion.substanceColor.swiftUIColor)
            if !suggestion.dosesAndUnit.isEmpty {
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
                                    estimatedDoseStandardDeviation: doseAndUnit.estimatedDoseStandardDeviation))
                            .buttonStyle(.bordered).fixedSize()
                        } else {
                            NavigationLink("Unknown", value: FinishIngestionScreenArguments(
                                substanceName: suggestion.substanceName,
                                administrationRoute: suggestion.route,
                                dose: doseAndUnit.dose,
                                units: doseAndUnit.units,
                                isEstimate: doseAndUnit.isEstimate,
                                estimatedDoseStandardDeviation: nil
                            ))
                            .buttonStyle(.bordered).fixedSize()
                        }
                    }
                    if let units = suggestion.dosesAndUnit.first?.units {
                        if let substance = suggestion.substance {
                            NavigationLink(
                                "Log \(units)",
                                value: SubstanceAndRoute(substance: substance, administrationRoute: suggestion.route))
                            .buttonStyle(.borderedProminent).fixedSize()
                        } else {
                            NavigationLink("Log \(units)", value: CustomChooseDoseScreenArguments(
                                substanceName: suggestion.substanceName,
                                units: units,
                                administrationRoute: suggestion.route))
                            .buttonStyle(.borderedProminent).fixedSize()
                        }
                    }
                }
            }
            if !suggestion.customUnitDoses.isEmpty || !suggestion.customUnits.isEmpty {
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
                                estimatedDoseStandardDeviation: customUnitDose.estimatedStandardDeviation,
                                customUnit: customUnitDose.customUnit))
                        {
                            CustomUnitDoseLabel(customUnitDose: customUnitDose)
                        }.buttonStyle(.bordered).fixedSize()
                    }
                    ForEach(suggestion.customUnits) { customUnit in
                        NavigationLink(value: customUnit) {
                            VStack {
                                Text(customUnit.nameUnwrapped).font(.caption2)
                                Text("Log \(customUnit.pluralizableUnit.plural)")
                            }
                        }.buttonStyle(.borderedProminent).fixedSize()
                    }
                    Button {
                        isAddCustomUnitSheetShown = true
                    } label: {
                        VStack {
                            Image(systemName: "pills").font(.caption)
                            Text("New unit")
                        }
                    }.buttonStyle(.borderedProminent).fixedSize()
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 10)
        .padding(.horizontal)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .sheet(isPresented: $isAddCustomUnitSheetShown, content: {
            NavigationStack {
                FinishCustomUnitsScreen(
                    arguments: customUnitArguments,
                    cancel: {
                        isAddCustomUnitSheetShown = false
                    },
                    onAdded: { customUnit in
                        isAddCustomUnitSheetShown = false
                        navigateToCustomUnitChooseDose(customUnit)
                    })
            }
        })
    }

    var customUnitArguments: CustomUnitArguments {
        if let substance = suggestion.substance {
            return CustomUnitArguments.substance(substance: substance, administrationRoute: suggestion.route)
        } else {
            return CustomUnitArguments.customSubstance(
                customSubstanceName: suggestion.substanceName,
                administrationRoute: suggestion.route,
                customSubstanceUnit: suggestion.dosesAndUnit.first?.units ?? "mg")
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
                            estimatedDoseStandardDeviation: 2),
                        RegularDoseAndUnit(
                            dose: nil,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseStandardDeviation: nil),
                        RegularDoseAndUnit(
                            dose: 30,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseStandardDeviation: nil),
                    ],
                    customUnitDoses: [],
                    customUnits: [],
                    lastCreationTime: Date.now.addingTimeInterval(-2 * 60 * 60)),
                dismiss: { },
                isEyeOpen: true,
                navigateToCustomUnitChooseDose: {_ in })
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
                            estimatedDoseStandardDeviation: nil),
                        RegularDoseAndUnit(
                            dose: 6,
                            units: "mg",
                            isEstimate: true,
                            estimatedDoseStandardDeviation: 1),
                        RegularDoseAndUnit(
                            dose: nil,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseStandardDeviation: nil),
                        RegularDoseAndUnit(
                            dose: 2.5,
                            units: "mg",
                            isEstimate: false,
                            estimatedDoseStandardDeviation: nil),
                    ],
                    customUnitDoses: [],
                    customUnits: [],
                    lastCreationTime: Date.now.addingTimeInterval(-3 * 60 * 60)),
                dismiss: { },
                isEyeOpen: true,
                navigateToCustomUnitChooseDose: {_ in })
        }
    }
}
