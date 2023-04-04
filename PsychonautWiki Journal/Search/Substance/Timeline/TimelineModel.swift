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
    let ratingDrawables: [RatingDrawable]
    let axisDrawable: AxisDrawable

    init(everythingForEachLine: [EverythingForOneLine], everythingForEachRating: [EverythingForOneRating]) {
        let potentialStartTimes = everythingForEachLine.map({ one in
            one.startTime
        }) + everythingForEachRating.map { $0.time }
        let minTime = potentialStartTimes.min() ?? Date()
        let timePadding: TimeInterval = 10*60
        let startTime = minTime.addingTimeInterval(-timePadding)
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
        let ratingDrawables = everythingForEachRating.map({ rating in
            RatingDrawable(startGraph: startTime, time: rating.time, option: rating.option)
        })
        self.ratingDrawables = ratingDrawables
        let twoHours: TimeInterval = 2 * 60 * 60
        let potentialTotalWidth = drawablesWithoutInsets.map({ draw in
            draw.distanceFromStart + draw.timelineDrawable.width
        }) + ratingDrawables.map { $0.distanceFromStart }
        let maxWidth: TimeInterval = potentialTotalWidth.max() ?? twoHours
        let totalWidth = maxWidth + timePadding
        self.totalWidth = totalWidth
        self.axisDrawable = AxisDrawable(startTime: startTime, widthInSeconds: totalWidth)
    }
}
