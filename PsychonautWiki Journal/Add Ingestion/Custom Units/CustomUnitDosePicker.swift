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
    let isDoseEstimated: Bool
    @Binding var dose: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(customUnit.nameUnwrapped).font(.headline)
            CustomUnitDoseRow(customUnit: customUnit.minInfo, roaDose: customUnit.roaDose)
            doseCalculationText.foregroundStyle(calculatedDoseColor)
            HStack {
                TextField(
                    "Enter Dose",
                    value: $dose,
                    format: .number).keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(calculatedDoseColor)
                Text((dose ?? 0).justUnit(unit: customUnit.unitUnwrapped))
            }
            .font(.title)
        }
    }

    private var calculatedDose: Double? {
        guard let dose, let dosePerUnit = customUnit.doseUnwrapped else { return nil }
        return dose * dosePerUnit
    }

    private var calculatedDoseColor: Color {
        if let calculatedDose {
            customUnit.roaDose?.getRangeType(for: calculatedDose, with: customUnit.originalUnitUnwrapped).color ?? Color.primary
        } else {
            Color.primary
        }
    }

    private var calculatedDoseTilde: String {
        if isDoseEstimated || customUnit.isEstimate {
            "~"
        } else {
            ""
        }
    }

    private var doseCalculationText: Text {
        if let calculatedDose {
            Text("\(calculatedDoseTilde)\(calculatedDose.formatted()) \(customUnit.originalUnitUnwrapped)").fontWeight(.bold) +
            Text(
                " = \(isDoseEstimated ? "~" : "")\(dose?.with(unit: customUnit.unitUnwrapped) ?? "...") x \(customUnit.isEstimate ? "~" : "")\(customUnit.doseUnwrapped?.formatted() ?? "unknown") \(customUnit.originalUnitUnwrapped)")

        } else {
            Text(" ")
        }
    }
}

#Preview {
    CustomUnitDosePicker(
        customUnit: .previewSample,
        isDoseEstimated: true,
        dose: .constant(3))
}
