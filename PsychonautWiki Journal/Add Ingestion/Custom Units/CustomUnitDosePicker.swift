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

    private var customUnitDose: CustomUnitDose? {
        if let dose {
            return CustomUnitDose(
                dose: dose,
                isEstimate: isEstimate,
                estimatedDoseVariance: estimatedDoseVariance,
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
