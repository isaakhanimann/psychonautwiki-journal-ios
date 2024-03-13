// Copyright (c) 2022. Isaak Hanimann.
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

struct ToleranceSection: View {
    let substance: Substance

    var body: some View {
        Section {
            if let full = substance.tolerance?.full {
                RowLabelView(label: "full", value: full)
            }
            if let half = substance.tolerance?.half {
                RowLabelView(label: "half", value: half)
            }
            if let zero = substance.tolerance?.zero {
                RowLabelView(label: "zero", value: zero)
            }
            let crossTolerances = substance.crossTolerances.joined(separator: ", ")
            if !crossTolerances.isEmpty {
                Text("Cross tolerance with \(crossTolerances)")
            }
        } header: {
            Text("Tolerance")
        } footer: {
            Text("* zero is the time to no tolerance")
        }

    }
}

#Preview {
    List {
        ToleranceSection(substance: SubstanceRepo.shared.getSubstance(name: "Amphetamine")!)
    }
}
