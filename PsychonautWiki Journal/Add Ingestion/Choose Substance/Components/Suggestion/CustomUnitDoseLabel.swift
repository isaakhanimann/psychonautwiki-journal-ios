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

struct CustomUnitDoseLabel: View {

    let customUnitDose: CustomUnitDose

    var body: some View {
        VStack {
            Text(customUnitDose.doseDescription)
            if let calculatedDoseDescription = customUnitDose.calculatedDoseDescription {
                Text(calculatedDoseDescription).font(.caption2)
            }
        }
    }

    private var maybeSign: String {
        customUnitDose.isEstimate ? "~" : ""
    }

    private var maybeSignPure: String {
        if customUnitDose.isEstimate || customUnitDose.customUnit.isEstimate {
            "~"
        } else {
            ""
        }
    }
}

#Preview {
    VStack {
        Button {

        } label: {
            CustomUnitDoseLabel(
                customUnitDose: CustomUnitDose(
                    dose: 2,
                    isEstimate: true,
                    estimatedDoseVariance: 0.5,
                    customUnit: .previewSample)
            )
        }.buttonStyle(.bordered)
        Button {

        } label: {
            CustomUnitDoseLabel(
                customUnitDose: CustomUnitDose(
                    dose: 2,
                    isEstimate: false,
                    estimatedDoseVariance: nil,
                    customUnit: .previewSample)
            )
        }.buttonStyle(.bordered)

        Button {

        } label: {
            CustomUnitDoseLabel(
                customUnitDose: CustomUnitDose(
                    dose: 2,
                    isEstimate: false,
                    estimatedDoseVariance: nil,
                    customUnit: .estimatedQuantitativelyPreviewSample)
            )
        }.buttonStyle(.bordered)
    }
}
