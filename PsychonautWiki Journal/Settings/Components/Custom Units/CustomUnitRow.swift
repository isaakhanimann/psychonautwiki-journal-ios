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

struct CustomUnitRow: View {
    let customUnit: CustomUnit

    var body: some View {
        HStack(spacing: 10) {
            ColorRectangle(color: customUnit.color?.swiftUIColor ?? Color.gray)
            VStack(alignment: .leading) {
                Text("\(customUnit.substanceNameUnwrapped) \(customUnit.nameUnwrapped)").font(.headline)
                Group {
                    if let dose = customUnit.doseUnwrapped {
                        Text(
                            "\(customUnit.isEstimate ? "~" : "")\(dose.formatted()) \(customUnit.originalUnitUnwrapped) per \(customUnit.unitUnwrapped)")
                    } else {
                        Text("\(customUnit.unitUnwrapped) of unknown dose")
                    }
                }
                .font(.subheadline)
            }
        }
    }
}

#Preview {
    List {
        CustomUnitRow(customUnit: CustomUnit.previewSample)
    }
}
