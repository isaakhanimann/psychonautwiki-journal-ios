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

extension StrokeStyle {
    static func getNormal(lineWidth: CGFloat) -> StrokeStyle {
        return StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
    }

    static func getDotted(lineWidth: CGFloat) -> StrokeStyle {
        return StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round,
            lineJoin: .round,
            dash: [10, 10],
            dashPhase: 0
        )
    }

    static let timedNoteLineWidth: Double = 3

    static func getTimedNoteStokeStyle() -> StrokeStyle {
        return StrokeStyle(
            lineWidth: timedNoteLineWidth,
            lineCap: .round,
            lineJoin: .round,
            dash: [5, 8],
            dashPhase: 0
        )
    }
}
