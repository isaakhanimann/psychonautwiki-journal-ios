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

struct CustomSubstanceSuggestionView: View {

    let customSubstanceSuggestions: CustomSubstanceSuggestions
    let isEyeOpen: Bool

    var body: some View {
        VStack(alignment: .leading) {
            let administrationRoute = customSubstanceSuggestions.administrationRoute
            let routeText = isEyeOpen ? administrationRoute.rawValue.localizedCapitalized : ""
            Label(
                "\(customSubstanceSuggestions.customSubstanceName) \(routeText)",
                systemImage: "circle.fill")
            .font(.headline)
            .foregroundColor(customSubstanceSuggestions.substanceColor.swiftUIColor)
            WrappingHStack(
                alignment: .leading,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing)
            {
                ForEach(customSubstanceSuggestions.dosesAndUnit) { doseAndUnit in
                    if let doseDescription = doseAndUnit.doseDescription {
                        NavigationLink(
                            doseDescription,
                            value: FinishIngestionScreenArguments(
                                substanceName: customSubstanceSuggestions.customSubstanceName,
                                administrationRoute: administrationRoute,
                                dose: doseAndUnit.dose,
                                units: doseAndUnit.units,
                                isEstimate: doseAndUnit.isEstimate,
                                estimatedDoseStandardDeviation: doseAndUnit.estimatedDoseStandardDeviation))
                        .buttonStyle(.bordered).fixedSize()
                    } else {
                        NavigationLink("Unknown", value: FinishIngestionScreenArguments(
                            substanceName: customSubstanceSuggestions.customSubstanceName,
                            administrationRoute: administrationRoute,
                            dose: doseAndUnit.dose,
                            units: doseAndUnit.units,
                            isEstimate: doseAndUnit.isEstimate,
                            estimatedDoseStandardDeviation: nil
                        ))
                        .buttonStyle(.bordered).fixedSize()
                    }
                }
                if let units = customSubstanceSuggestions.dosesAndUnit.first?.units {
                    NavigationLink("Other dose", value: CustomChooseDoseScreenArguments(
                        substanceName: customSubstanceSuggestions.customSubstanceName,
                        units: units,
                        administrationRoute: administrationRoute))
                    .buttonStyle(.borderedProminent).fixedSize()
                }
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
        CustomSubstanceSuggestionView(customSubstanceSuggestions: CustomSubstanceSuggestions(administrationRoute: .oral, customSubstanceName: "Amanita muscaria", dosesAndUnit: [
            RegularDoseAndUnit(dose: 3, units: "g", isEstimate: false, estimatedDoseStandardDeviation: nil),
            RegularDoseAndUnit(dose: 4, units: "g", isEstimate: true, estimatedDoseStandardDeviation: 1)
        ], substanceColor: .orange, sortDate: .now), isEyeOpen: true)
    }
}
