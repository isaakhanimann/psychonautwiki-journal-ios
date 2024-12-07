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
    // e.g. for 2.with(unit: "experience") it returns "2 experiences"
    func with(pluralizableUnit: PluralizableUnit) -> String {
        if Double(self).isPlural {
            "\(self) \(pluralizableUnit.plural)"
        } else {
            "\(self) \(pluralizableUnit.singular)"
        }
    }
}

extension Double {
    func with(pluralizableUnit: PluralizableUnit) -> String {
        if isPlural {
            "\(self.asRoundedReadableString) \(pluralizableUnit.plural)"
        } else {
            "\(self.asRoundedReadableString) \(pluralizableUnit.singular)"
        }
    }

    func justUnit(pluralizableUnit: PluralizableUnit) -> String {
        if isPlural {
            pluralizableUnit.plural
        } else {
            pluralizableUnit.singular
        }
    }

    var isPlural: Bool {
        self != 1
    }
}
