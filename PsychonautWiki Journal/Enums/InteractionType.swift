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

enum InteractionType {
    case uncertain, unsafe, dangerous

    var color: Color {
        switch self {
        case .uncertain:
            return Color.yellow
        case .unsafe:
            return Color.orange
        case .dangerous:
            return Color.red
        }
    }

    var dangerCount: Int {
        switch self {
        case .uncertain:
            return 1
        case .unsafe:
            return 2
        case .dangerous:
            return 3
        }
    }
}
