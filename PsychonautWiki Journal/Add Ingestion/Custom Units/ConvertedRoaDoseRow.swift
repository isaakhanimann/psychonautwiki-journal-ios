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

struct ConvertedRoaDoseRow: View {

    let customUnit: CustomUnit
    let roaDose: RoaDose?

    var body: some View {
        DoseClassificationRow(
            lightMin: convertToNewUnit(oldDose: roaDose?.lightMin),
            commonMin: convertToNewUnit(oldDose: roaDose?.commonMin),
            strongMin: convertToNewUnit(oldDose: roaDose?.strongMin),
            heavyMin: convertToNewUnit(oldDose: roaDose?.heavyMin),
            units: customUnit.unitUnwrapped)
    }

    private func convertToNewUnit(oldDose: Double?) -> Double? {
        if let oldDose, let dosePerUnit = customUnit.doseUnwrapped, dosePerUnit > 0 {
            (oldDose/dosePerUnit).relativeRounded
        } else {
            nil
        }
    }
}

#Preview {
    ConvertedRoaDoseRow(
        customUnit: CustomUnit.previewSample,
        roaDose: SubstanceRepo.shared.getSubstance(name: "MDMA")!.getDose(for: .oral))
}
