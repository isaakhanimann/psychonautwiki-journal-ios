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

enum ToleranceChartPreviewDataProvider {
    static let mock1: [ToleranceWindow] = [
        ToleranceWindow(substanceName: "MDMA",
                        start: getDate(year: 2023, month: 2, day: 1)!,
                        end: getDate(year: 2023, month: 4, day: 1)!,
                        toleranceType: .full,
                        substanceColor: .pink),
        ToleranceWindow(substanceName: "MDMA",
                        start: getDate(year: 2023, month: 4, day: 1)!,
                        end: getDate(year: 2023, month: 5, day: 1)!,
                        toleranceType: .half,
                        substanceColor: .pink),
        ToleranceWindow(substanceName: "Ketamine",
                        start: getDate(year: 2023, month: 2, day: 10)!,
                        end: getDate(year: 2023, month: 2, day: 20)!,
                        toleranceType: .full,
                        substanceColor: .blue),
        ToleranceWindow(substanceName: "Ketamine",
                        start: getDate(year: 2023, month: 2, day: 20)!,
                        end: getDate(year: 2023, month: 2, day: 30)!,
                        toleranceType: .half,
                        substanceColor: .blue),
    ]
}
