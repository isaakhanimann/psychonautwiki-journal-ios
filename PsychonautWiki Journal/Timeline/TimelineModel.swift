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

struct TimelineModel: Hashable {
    static func == (lhs: TimelineModel, rhs: TimelineModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        // some unique hash
        hasher.combine(startTime)
        hasher.combine(totalWidth)
        hasher.combine(groupDrawables.description)
        hasher.combine(timeRangeDrawables.description)
        hasher.combine(ratingDrawables.description)
        hasher.combine(timedNoteDrawables.description)
        hasher.combine(axisDrawable.widthInSeconds)
    }

    let startTime: Date
    let totalWidth: TimeInterval
    let groupDrawables: [GroupDrawable]
    let timeRangeDrawables: [TimeRangeDrawable]
    let ratingDrawables: [RatingDrawable]
    let timedNoteDrawables: [TimedNoteDrawable]
    let axisDrawable: AxisDrawable

    var isWorthDrawing: Bool {
        let allHaveMissingDuration = groupDrawables.allSatisfy { groupDrawable in
            !groupDrawable.hasDurationInfo
        }
        return !(allHaveMissingDuration && ratingDrawables.isEmpty && timedNoteDrawables.isEmpty)
    }

    struct RoaGroup {
        let color: SubstanceColor
        let roaDuration: RoaDuration?
        let weightedLines: [WeightedLine]
        let ingestionRanges: [IngestionRange]
    }

    // swiftlint:disable function_body_length
    init(
        substanceGroups: [SubstanceIngestionGroup],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote],
        areRedosesDrawnIndividually: Bool,
        areSubstanceHeightsIndependent: Bool
    ) {

        let startTime = Self.getStartTime(
            substanceGroups: substanceGroups,
            everythingForEachRating: everythingForEachRating,
            everythingForEachTimedNote: everythingForEachTimedNote
        )
        self.startTime = startTime
        let substanceGroupsWithRepoInfo = getSubstanceGroupWithRepoInfo(substanceIngestionGroups: substanceGroups)
        var roaGroups: [RoaGroup] = []
        for substanceGroup in substanceGroupsWithRepoInfo {
            for routeGroup in substanceGroup.routeGroups {
                let ingestionRanges = routeGroup.ingestions.compactMap { ingestion in
                    if let endTime = ingestion.endTime {
                        IngestionRange(startTime: ingestion.time, endTime: endTime)
                    } else {
                        nil
                    }
                }
                let group = RoaGroup(
                    color: substanceGroup.color,
                    roaDuration: routeGroup.roaDuration,
                    weightedLines: routeGroup.ingestions.map { ingestion in
                        WeightedLine(
                            startTime: ingestion.time,
                            endTime: ingestion.endTime,
                            horizontalWeight: ingestion.horizontalWeight,
                            strengthRelativeToCommonDose: ingestion.strengthRelativeToCommonDose,
                            onsetDelayInHours: ingestion.onsetDelayInHours
                        )
                    },
                    ingestionRanges: ingestionRanges
                )
                roaGroups.append(group)
            }
        }
        var groupDrawables = roaGroups.map { group in
            GroupDrawable(
                startGraph: startTime,
                color: group.color,
                roaDuration: group.roaDuration,
                weightedLines: group.weightedLines,
                areRedosesDrawnIndividually: areRedosesDrawnIndividually,
                areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
            )
        }.sorted { lhs, rhs in
            lhs.startInSeconds < rhs.startInSeconds
        } // sort makes sure that lines are always drawn in the same order such that lines with a later ingestion time are drawn on top.
        let maxHeight = groupDrawables.map { group in
            group.nonNormalizedHeight
        }.max() ?? 1
        for (index, _) in groupDrawables.enumerated() {
            groupDrawables[index].normalize(maxHeight: maxHeight)
        }
        self.groupDrawables = groupDrawables
        let intermediateRange = roaGroups.flatMap({ group in
            group.ingestionRanges.map { range in
                let startInSeconds = startTime.distance(to: range.startTime)
                let endInSeconds = startTime.distance(to: range.endTime)
                return TimeRangeDrawable.IntermediateRepresentation(color: group.color, startInSeconds: startInSeconds, endInSeconds: endInSeconds)
            }
        }).sorted { lhs, rhs in
            lhs.rangeInSeconds.lowerBound < rhs.rangeInSeconds.lowerBound
        }
        let timeRangeDrawables = intermediateRange.enumerated().map { index, currentRange in
            let intersectionCount = intermediateRange[..<index].filter {
                $0.rangeInSeconds.overlaps(currentRange.rangeInSeconds)
            }.count
            return TimeRangeDrawable(
                color: currentRange.color,
                startInSeconds: currentRange.rangeInSeconds.lowerBound,
                endInSeconds: currentRange.rangeInSeconds.upperBound,
                intersectionCountWithPreviousRanges: intersectionCount
            )
        }
        self.timeRangeDrawables = timeRangeDrawables
        let ratingDrawables = everythingForEachRating.map { rating in
            RatingDrawable(startGraph: startTime, time: rating.time, option: rating.option)
        }
        self.ratingDrawables = ratingDrawables
        let timedNoteDrawables = everythingForEachTimedNote.map { timedNote in
            TimedNoteDrawable(startGraph: startTime, time: timedNote.time, color: timedNote.color)
        }
        self.timedNoteDrawables = timedNoteDrawables
        let sixHours: TimeInterval = 6 * 60 * 60
        let widthOfTimelinesAndRatings = groupDrawables.map { group in
            group.endRelativeToStartInSeconds
        } + ratingDrawables.map { $0.distanceFromStart } + timedNoteDrawables.map { $0.distanceFromStart } + timeRangeDrawables.map { $0.endInSeconds }
        let maxWidth: TimeInterval = (widthOfTimelinesAndRatings.max() ?? sixHours)
        totalWidth = maxWidth
        axisDrawable = AxisDrawable(startTime: startTime, widthInSeconds: maxWidth)
    }
    // swiftlint:enable function_body_length

    private static func getStartTime(
        substanceGroups: [SubstanceIngestionGroup],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote]
    ) -> Date {
        let ingestionTimes = substanceGroups.flatMap { group in
            group.routeMinInfos.flatMap { route in
                route.ingestions.map { $0.time }
            }
        }
        let potentialStartTimes = ingestionTimes + everythingForEachRating.map { $0.time } + everythingForEachTimedNote.map { $0.time }
        return potentialStartTimes.min() ?? Date()
    }
}
