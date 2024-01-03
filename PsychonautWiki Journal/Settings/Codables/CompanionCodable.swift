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

struct CompanionCodable: Codable {
    let substanceName: String
    let color: SubstanceColor

    enum CodingKeys: String, CodingKey {
        case substanceName
        case color
    }

    init(substanceName: String, color: SubstanceColor) {
        self.substanceName = substanceName
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        substanceName = try values.decode(String.self, forKey: .substanceName)
        color = try values.decode(SubstanceColor.self, forKey: .color)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(substanceName, forKey: .substanceName)
        try container.encode(color.rawValue, forKey: .color)
    }
}
