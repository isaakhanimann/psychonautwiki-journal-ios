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

import Foundation
import SwiftUI

// https://psychonautwiki.org/wiki/Route_of_administration
enum AdministrationRoute: String, Codable, CaseIterable, Identifiable {
    case oral
    case sublingual
    case buccal
    case insufflated
    case rectal
    case transdermal
    case subcutaneous
    case intramuscular
    case intravenous
    case smoked
    case inhaled

    var id: String {
        rawValue
    }

    var clarification: String {
        switch self {
        case .oral:
            return "swallowed"
        case .sublingual:
            return "under the tongue"
        case .buccal:
            return "between gums and cheek"
        case .insufflated:
            return "sniffed"
        case .rectal:
            return "up the butt"
        case .transdermal:
            return "through skin"
        case .subcutaneous:
            return "injected below skin"
        case .intramuscular:
            return "injected into muscle"
        case .intravenous:
            return "injected into vein"
        case .smoked:
            return "heating/burning"
        case .inhaled:
            return "vapor/gas"
        }
    }

    var color: SubstanceColor {
        switch self {
        case .oral:
            return .blue
        case .sublingual:
            return .cyan
        case .buccal:
            return .teal
        case .insufflated:
            return .orange
        case .rectal:
            return .pink
        case .transdermal:
            return .yellow
        case .subcutaneous:
            return .mint
        case .intramuscular:
            return .brown
        case .intravenous:
            return .red
        case .smoked:
            return .green
        case .inhaled:
            return .purple
        }
    }
}
