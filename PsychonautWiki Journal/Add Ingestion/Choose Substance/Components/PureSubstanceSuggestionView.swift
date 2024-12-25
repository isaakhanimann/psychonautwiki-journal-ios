// Copyright (c) 2024. Isaak Hanimann.
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

struct PureSubstanceSuggestionView: View {

    let pureSubstanceSuggestions: PureSubstanceSuggestions
    let isEyeOpen: Bool

    var body: some View {
        VStack(alignment: .leading) {
            let routeText = isEyeOpen ? pureSubstanceSuggestions.route.rawValue.localizedCapitalized : ""
            Label(
                "\(pureSubstanceSuggestions.substance.name) \(routeText)",
                systemImage: "circle.fill")
            .font(.headline)
            .foregroundColor(pureSubstanceSuggestions.substanceColor.swiftUIColor)
            WrappingHStack(
                alignment: .leading,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing)
            {
                ForEach(pureSubstanceSuggestions.dosesAndUnit) { doseAndUnit in
                    if let doseDescription = doseAndUnit.doseDescription {
                        NavigationLink(
                            doseDescription,
                            value: FinishIngestionScreenArguments(
                                substanceName: pureSubstanceSuggestions.substance.name,
                                administrationRoute: pureSubstanceSuggestions.route,
                                dose: doseAndUnit.dose,
                                units: doseAndUnit.units,
                                isEstimate: doseAndUnit.isEstimate,
                                estimatedDoseStandardDeviation: doseAndUnit.estimatedDoseStandardDeviation))
                        .buttonStyle(.bordered).fixedSize()
                    } else {
                        NavigationLink("Unknown", value: FinishIngestionScreenArguments(
                            substanceName: pureSubstanceSuggestions.substance.name,
                            administrationRoute: pureSubstanceSuggestions.route,
                            dose: doseAndUnit.dose,
                            units: doseAndUnit.units,
                            isEstimate: doseAndUnit.isEstimate,
                            estimatedDoseStandardDeviation: nil
                        ))
                        .buttonStyle(.bordered).fixedSize()
                    }
                }
                NavigationLink(
                    "Other dose",
                    value: SubstanceAndRoute(substance: pureSubstanceSuggestions.substance, administrationRoute: pureSubstanceSuggestions.route))
                .buttonStyle(.borderedProminent).fixedSize()
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 10)
        .padding(.horizontal)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private let horizontalSpacing: Double = 4
    private let verticalSpacing: Double = 5
}

#Preview {
    NavigationStack {
        PureSubstanceSuggestionView(
            pureSubstanceSuggestions: PureSubstanceSuggestions(route: .oral, substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!, substanceColor: .pink, dosesAndUnit: [
                RegularDoseAndUnit(dose: 50, units: "mg", isEstimate: false, estimatedDoseStandardDeviation: nil),
                RegularDoseAndUnit(dose: 80, units: "mg", isEstimate: false, estimatedDoseStandardDeviation: nil),
                RegularDoseAndUnit(dose: 120, units: "mg", isEstimate: false, estimatedDoseStandardDeviation: nil),
                RegularDoseAndUnit(dose: 30, units: "mg", isEstimate: false, estimatedDoseStandardDeviation: nil),
                RegularDoseAndUnit(dose: 100, units: "mg", isEstimate: true, estimatedDoseStandardDeviation: 20)
            ], sortDate: .now),
            isEyeOpen: true)
    }
}
