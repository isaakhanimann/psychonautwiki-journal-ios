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

struct CustomUnitDosePicker: View {

    let customUnit: CustomUnit
    @Binding var dose: Double?
    @Binding var isEstimate: Bool
    @Binding var estimatedDoseVariance: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(customUnit.nameUnwrapped).font(.headline)
            CustomUnitDoseRow(customUnit: customUnit.minInfo, roaDose: customUnit.roaDose)
            doseCalculationText.foregroundStyle(calculatedDoseColor)
            HStack {
                TextField(
                    "Enter Dose",
                    value: $dose,
                    format: .number
                )
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                Text((dose ?? 0).justUnit(unit: customUnit.unitUnwrapped))
            }
            .font(.title)
            Toggle("Dose is an Estimate", isOn: $isEstimate).tint(.accentColor)
            if isEstimate {
                HStack {
                    Image(systemName: "plusminus")
                    TextField(
                        "Pure dose variance",
                        value: $estimatedDoseVariance,
                        format: .number
                    ).keyboardType(.decimalPad)
                    Spacer()
                    Text(customUnit.unitUnwrapped)
                }
            }
        }
    }

    private var calculatedDose: Double? {
        guard let dose, let dosePerUnit = customUnit.doseUnwrapped else { return nil }
        if let customDoseVariance = customUnit.estimatedDoseVarianceUnwrapped, let estimatedDoseVariance, isEstimate {
            let minDose = dose - estimatedDoseVariance
            let maxDose = dose + estimatedDoseVariance
            let minCustomDose = dosePerUnit - customDoseVariance
            let maxCustomDose = dosePerUnit + customDoseVariance
            let minResult = minDose * minCustomDose
            let maxResult = maxDose * maxCustomDose
            let result = (minResult + maxResult) / 2
            return result
        } else {
            return dose * dosePerUnit
        }
    }

    private var calculatedDoseVariance: Double? {
        guard let dose, let dosePerUnit = customUnit.doseUnwrapped, let customDoseVariance = customUnit.estimatedDoseVarianceUnwrapped else { return nil }
        if let estimatedDoseVariance, isEstimate {
            let minDose = dose - estimatedDoseVariance
            let maxDose = dose + estimatedDoseVariance
            let minCustomDose = dosePerUnit - customDoseVariance
            let maxCustomDose = dosePerUnit + customDoseVariance
            let minResult = minDose * minCustomDose
            let maxResult = maxDose * maxCustomDose
            let result = (minResult + maxResult) / 2
            let resultVariance = maxResult - result
            return resultVariance
        } else {
            return dose * customDoseVariance
        }
    }

    private var calculatedDoseColor: Color {
        if let calculatedDose {
            customUnit.roaDose?.getRangeType(for: calculatedDose, with: customUnit.originalUnitUnwrapped).color ?? Color.primary
        } else {
            Color.primary
        }
    }

    private var calculatedDoseDescription: String {
        if let calculatedDose {
            if let calculatedDoseVariance {
                return "\(calculatedDose.formatted())±\(calculatedDoseVariance.formatted()) \(customUnit.originalUnitUnwrapped)"
            } else {
                let description = "\(calculatedDose.formatted()) \(customUnit.originalUnitUnwrapped)"
                if isEstimate || customUnit.isEstimate {
                    return "~\(description)"
                } else {
                    return description
                }
            }
        } else {
            return ""
        }
    }

    private var enteredDoseDescription: String {
        if let dose {
            let description = "\(dose.with(unit: customUnit.unitUnwrapped))"
            if isEstimate {
                if let estimatedDoseVariance {
                    return "\(dose.formatted())±\(estimatedDoseVariance.with(unit: customUnit.unitUnwrapped))"
                } else {
                    return "~\(description)"
                }
            } else {
                return description
            }
        } else {
            return ""
        }
    }

    private var doseCalculationText: Text {
        if calculatedDose != nil {
            Text(calculatedDoseDescription).fontWeight(.bold) +
            Text(
                " = \(enteredDoseDescription) x \(customUnit.doseOfOneUnitDescription)")

        } else {
            Text(" ")
        }
    }
}

struct CustomUnitsDosePickerPreviewContainer: View {

    @State private var dose: Double? = 3.0
    @State private var isEstimate = false
    @State private var estimatedDoseVariance: Double? = 0.5

    var body: some View {
        CustomUnitDosePicker(
            customUnit: .estimatedQuantitativelyPreviewSample,
            dose: $dose,
            isEstimate: $isEstimate,
            estimatedDoseVariance: $estimatedDoseVariance)
    }
}

#Preview {
    CustomUnitsDosePickerPreviewContainer()
}
