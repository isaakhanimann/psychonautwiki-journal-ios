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
    let groupDrawables: [GroupDrawable]
    let ratingDrawables: [RatingDrawable]
    let timedNoteDrawables: [TimedNoteDrawable]
    let axisDrawable: AxisDrawable

    struct RoaGroup {
        let color: SubstanceColor
        let roaDuration: RoaDuration?
        let weightedLines: [WeightedLine]
    }

    init(
        everythingForEachLine: [EverythingForOneLine],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote],
        areRedosesDrawnIndividually: Bool
    ) {
        let potentialStartTimes = everythingForEachLine.map({ one in
            one.startTime
        }) + everythingForEachRating.map { $0.time } + everythingForEachTimedNote.map { $0.time }
        let startTime = potentialStartTimes.min() ?? Date()
        self.startTime = startTime
        let substanceDict = Dictionary(grouping: everythingForEachLine) { oneLine in
            oneLine.substanceName
        }
        var roaGroups: [RoaGroup] = []
        for linesPerSubstance in substanceDict.values {
            let roaDict = Dictionary(grouping: linesPerSubstance) { line in
                line.route
            }
            for linesPerRoute in roaDict.values {
                guard let firstLine = linesPerRoute.first else {continue}
                let group = RoaGroup(
                    color: firstLine.color,
                    roaDuration: firstLine.roaDuration,
                    weightedLines: linesPerRoute.map { l in
                        WeightedLine(
                            startTime: l.startTime,
                            horizontalWeight: l.horizontalWeight,
                            height: l.verticalWeight,
                            onsetDelayInHours: l.onsetDelayInHours
                        )
                    }
                )
                roaGroups.append(group)
            }
        }
        let groupDrawables = roaGroups.map { group in
            GroupDrawable(
                startGraph: startTime,
                color: group.color,
                roaDuration: group.roaDuration,
                weightedLines: group.weightedLines,
                areRedosesDrawnIndividually: areRedosesDrawnIndividually)
        }.sorted { lhs, rhs in
            lhs.endRelativeToStartInSeconds < rhs.endRelativeToStartInSeconds
        } // sort makes sure that lines are always drawn in the same order such that lines with a later endpoint are drawn on top.
        self.groupDrawables = groupDrawables
        let ratingDrawables = everythingForEachRating.map({ rating in
            RatingDrawable(startGraph: startTime, time: rating.time, option: rating.option)
        })
        self.ratingDrawables = ratingDrawables
        let timedNoteDrawables = everythingForEachTimedNote.map({ timedNote in
            TimedNoteDrawable(startGraph: startTime, time: timedNote.time, color: timedNote.color)
        })
        self.timedNoteDrawables = timedNoteDrawables
        let sixHours: TimeInterval = 6 * 60 * 60
        let widthOfTimelinesAndRatings = groupDrawables.map({ group in
            group.endRelativeToStartInSeconds
        }) + ratingDrawables.map { $0.distanceFromStart } + timedNoteDrawables.map { $0.distanceFromStart }
        let maxWidth: TimeInterval = (widthOfTimelinesAndRatings.max() ?? sixHours)
        self.totalWidth = maxWidth
        self.axisDrawable = AxisDrawable(startTime: startTime, widthInSeconds: maxWidth)
    }
}
