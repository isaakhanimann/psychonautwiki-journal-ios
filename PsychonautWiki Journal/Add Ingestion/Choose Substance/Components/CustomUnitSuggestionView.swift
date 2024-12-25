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

struct CustomUnitSuggestionView: View {

    let customUnitSuggestions: CustomUnitSuggestions
    let isEyeOpen: Bool

    var body: some View {
        VStack(alignment: .leading) {
            let customUnit = customUnitSuggestions.customUnit
            let substanceName = customUnit.substanceNameUnwrapped
            let administrationRoute = customUnit.administrationRouteUnwrapped
            let routeText = isEyeOpen ? administrationRoute.rawValue.localizedCapitalized : ""
            Label(
                "\(substanceName) \(routeText), \(customUnit.nameUnwrapped)",
                systemImage: "circle.fill")
            .font(.headline)
            .foregroundColor(customUnitSuggestions.substanceColor.swiftUIColor)
            WrappingHStack(
                alignment: .leading,
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing)
            {
                ForEach(customUnitSuggestions.doses) { customUnitDoseSuggestion in
                    NavigationLink(
                        value: FinishIngestionScreenArguments(
                            substanceName: substanceName,
                            administrationRoute: administrationRoute,
                            dose: customUnitDoseSuggestion.dose,
                            units: customUnit.originalUnitUnwrapped,
                            isEstimate: customUnitDoseSuggestion.isEstimate,
                            estimatedDoseStandardDeviation: customUnitDoseSuggestion.estimatedStandardDeviation,
                            customUnit: customUnit))
                    {
                        OneCustomUnitDoseSuggestionView(
                            customUnitDoseSuggestions: customUnitDoseSuggestion,
                            customUnit: customUnit
                        )
                    }.buttonStyle(.bordered).fixedSize()
                }
                NavigationLink(value: customUnit) {
                    Text("Other dose")
                }.buttonStyle(.borderedProminent).fixedSize()
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

private struct OneCustomUnitDoseSuggestionView: View {

    let customUnitDoseSuggestions: CustomUnitDoseSuggestion
    let customUnit: CustomUnit

    var body: some View {
        Text(doseDescription)
    }

    var doseDescription: String {
        if let dose = customUnitDoseSuggestions.dose {
            let description = dose.with(pluralizableUnit: customUnit.pluralizableUnit)
            if customUnitDoseSuggestions.isEstimate {
                if let estimatedStandardDeviation = customUnitDoseSuggestions.estimatedStandardDeviation {
                    return "\(dose.asRoundedReadableString)±\(estimatedStandardDeviation.asRoundedReadableString) \(dose.justUnit(pluralizableUnit: customUnit.pluralizableUnit))"
                } else {
                    return "~\(description)"
                }
            } else {
                return description
            }
        } else {
            return "Unknown"
        }
    }
}
