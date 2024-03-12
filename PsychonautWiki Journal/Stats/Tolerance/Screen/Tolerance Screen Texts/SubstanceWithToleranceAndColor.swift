// Copyright (c) 2023. Isaak Hanimann.
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

import Foundation

struct SubstanceWithToleranceAndColor: Identifiable, Hashable {
    var id: String {
        substanceName
    }

    let substanceName: String
    let full: String?
    let half: String?
    let zero: String?
    let crossTolerances: [String]
    let color: SubstanceColor
}

extension Substance {
    func toSubstanceWithToleranceAndColor(substanceColor: SubstanceColor) -> SubstanceWithToleranceAndColor {
        SubstanceWithToleranceAndColor(
            substanceName: name,
            full: tolerance?.full,
            half: tolerance?.half,
            zero: tolerance?.zero,
            crossTolerances: crossTolerances,
            color: substanceColor
        )
    }
}
