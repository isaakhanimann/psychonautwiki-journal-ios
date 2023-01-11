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

struct TimelineModel {
    let startTime: Date
    let totalWidth: TimeInterval
    let ingestionDrawables: [IngestionDrawable]
    let axisDrawable: AxisDrawable

    init(everythingForEachLine: [EverythingForOneLine]) {
        let startTime = everythingForEachLine.map({ one in
            one.startTime
        }).min() ?? Date()
        self.startTime = startTime
        let drawablesWithoutInsets = everythingForEachLine.map { one in
            IngestionDrawable(
                startGraph: startTime,
                color: one.color,
                ingestionTime: one.startTime,
                roaDuration: one.roaDuration,
                verticalWeight: one.verticalWeight,
                horizontalWeight: one.horizontalWeight
            )
        }
        self.ingestionDrawables = drawablesWithoutInsets
        let twoHours: TimeInterval = 2 * 60 * 60
        let maxWidth: TimeInterval = drawablesWithoutInsets.map({ draw in
            draw.distanceFromStart + draw.timelineDrawable.width
        }).max() ?? twoHours
        self.totalWidth = maxWidth
        self.axisDrawable = AxisDrawable(startTime: startTime, widthInSeconds: maxWidth)
    }
}
