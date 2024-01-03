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

import SwiftUI

struct ToleranceWindow: Identifiable {
    let id = UUID()
    let substanceName: String
    let start: Date
    let end: Date
    let toleranceType: ToleranceType
    let barColor: Color

    init(substanceName: String, start: Date, end: Date, toleranceType: ToleranceType, substanceColor: Color) {
        self.substanceName = substanceName
        self.start = start
        self.end = end
        self.toleranceType = toleranceType
        switch toleranceType {
        case .full:
            barColor = substanceColor
        case .half:
            barColor = substanceColor.opacity(0.5)
        }
    }

    func contains(date: Date) -> Bool {
        start <= date && end >= date
    }
}
