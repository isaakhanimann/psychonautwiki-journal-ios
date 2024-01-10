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

import Foundation

extension Int {
    // e.g. for 2.inflect(unit: "experience") it returns "2 experiences"
    func inflect(unit: String) -> LocalizedStringResource {
        "^[\(self) \(unit)](inflect: true)"
    }
}

extension Double {
    func inflect(unit: String) -> AttributedString {
        var string = AttributedString(localized: "\(self.formatted()) \(unit)")
        var morphology = Morphology()
        let number: Morphology.GrammaticalNumber
        switch self {
        case 0:
            number = .zero
        case 1:
            number = .singular
        default:
            number = .plural
        }
        morphology.number = number
        string.inflect = InflectionRule(morphology: morphology)
        let formattedResult = string.inflected()
        return formattedResult
    }
}
