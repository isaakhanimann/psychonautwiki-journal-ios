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

struct CustomUnitCalculationText: View {

    let customUnit: CustomUnit
    let dose: Double?
    let isEstimate: Bool
    let estimatedDoseStandardDeviation: Double?

    var body: some View {
        VStack(alignment: .leading) {
            doseCalculationText
            if let calculatedDose = customUnitDose?.calculatedDose, let calculatedStandardDeviation = customUnitDose?.calculatedStandardDeviation {
                Text("Meaning ") + Text(StandardDeviationConfidenceIntervals.getTwoStandardDeviationText(mean: calculatedDose, standardDeviation: calculatedStandardDeviation, unit: customUnit.originalUnitUnwrapped))
            }
        }.foregroundStyle(calculatedDoseColor)
    }

    private var customUnitDose: CustomUnitDose? {
        if let dose {
            return CustomUnitDose(
                dose: dose,
                isEstimate: isEstimate,
                estimatedStandardDeviation: estimatedDoseStandardDeviation,
                customUnit: customUnit)
        } else {
            return nil
        }
    }

    private var calculatedDoseColor: Color {
        if let calculatedDose = customUnitDose?.calculatedDose {
            customUnit.roaDose?.getRangeType(for: calculatedDose, with: customUnit.originalUnitUnwrapped).color ?? Color.primary
        } else {
            Color.primary
        }
    }

    private var doseCalculationText: Text {
        if let customUnitDose, let calculatedDoseDescription = customUnitDose.calculatedDoseDescription {
            Text(calculatedDoseDescription).fontWeight(.bold) +
            Text(
                " = \(customUnitDose.doseDescription) x \(customUnit.doseOfOneUnitDescription)")
        } else {
            Text(" ")
        }
    }
}

#Preview {
    CustomUnitCalculationText(
        customUnit: .estimatedQuantitativelyPreviewSample,
        dose: 3.0,
        isEstimate: true,
        estimatedDoseStandardDeviation: 0.5)
}
