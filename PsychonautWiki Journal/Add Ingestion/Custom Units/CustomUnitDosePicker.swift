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

    @FocusState private var isEstimatedVarianceFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomUnitDoseRow(customUnit: customUnit.minInfo, roaDose: customUnit.roaDose)
            HStack {
                TextField(
                    "Enter Dose",
                    value: $dose,
                    format: .number
                )
                .keyboardType(.decimalPad)
                Text((dose ?? 0).justUnit(unit: customUnit.unitUnwrapped))
            }
            .font(.title)
            Toggle("Dose is an Estimate", isOn: $isEstimate)
                .tint(.accentColor)
                .onChange(of: isEstimate, perform: { newIsEstimate in
                    if newIsEstimate {
                        isEstimatedVarianceFocused = true
                    }
                })
            if isEstimate {
                HStack {
                    Image(systemName: "plusminus")
                    TextField(
                        "Pure dose variance",
                        value: $estimatedDoseVariance,
                        format: .number
                    )
                    .keyboardType(.decimalPad)
                    .focused($isEstimatedVarianceFocused)
                    Spacer()
                    Text(customUnit.unitUnwrapped)
                }
            }
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
