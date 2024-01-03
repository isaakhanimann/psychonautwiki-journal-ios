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

struct EffectTimeline: View {
    let timelineModel: TimelineModel
    var height: Double = 200
    var isShowingCurrentTime = true
    var spaceToLabels = 5.0
    private let lineWidth: Double = 5
    private var halfLineWidth: Double {
        lineWidth / 2
    }

    var body: some View {
        VStack(spacing: 0) {
            timeLabels
            TimelineView(.everyMinute) { timeline in
                let timelineDate = timeline.date
                Canvas { context, size in
                    let pixelsPerSec = size.width / timelineModel.totalWidth
                    timelineModel.groupDrawables.forEach { groupDrawable in
                        groupDrawable.draw(
                            context: context,
                            height: size.height,
                            pixelsPerSec: pixelsPerSec,
                            lineWidth: lineWidth
                        )
                    }
                    timelineModel.ratingDrawables.forEach { ratingDrawable in
                        ratingDrawable.draw(
                            context: &context,
                            height: size.height,
                            pixelsPerSec: pixelsPerSec,
                            lineWidth: 3
                        )
                    }
                    timelineModel.timedNoteDrawables.forEach { timedNoteDrawable in
                        timedNoteDrawable.draw(
                            context: context,
                            height: size.height,
                            pixelsPerSec: pixelsPerSec,
                            lineWidth: 3
                        )
                    }
                    let shouldDrawCurrentTime = timelineDate > timelineModel.startTime.addingTimeInterval(2 * 60) && timelineDate < timelineModel.startTime.addingTimeInterval(timelineModel.totalWidth) && isShowingCurrentTime
                    if shouldDrawCurrentTime {
                        let currentTimeX = ((timelineDate.timeIntervalSinceReferenceDate - timelineModel.startTime.timeIntervalSinceReferenceDate) * pixelsPerSec) + halfLineWidth
                        var path = Path()
                        path.move(to: CGPoint(x: currentTimeX, y: 0))
                        path.addLine(to: CGPoint(x: currentTimeX, y: size.height))
                        context.stroke(path, with: .foreground, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    }
                }
            }
            .padding(.vertical, spaceToLabels)
            timeLabels
        }.frame(height: height)
    }

    private var timeLabels: some View {
        Canvas { context, size in
            let widthInPixels = size.width
            let pixelsPerSec = widthInPixels / timelineModel.totalWidth
            let fullHours = timelineModel.axisDrawable.getFullHours(
                pixelsPerSec: pixelsPerSec,
                widthInPixels: widthInPixels
            )
            fullHours.forEach { fullHour in
                context.draw(
                    Text(fullHour.label).font(.caption),
                    at: CGPoint(x: fullHour.distanceFromStart, y: size.height / 2),
                    anchor: .center
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct EffectTimeline_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                EffectTimeline(
                    timelineModel: TimelineModel(
                        substanceGroups: substanceGroups,
                        everythingForEachRating: everythingForEachRating,
                        everythingForEachTimedNote: everythingForEachTimedNote,
                        areRedosesDrawnIndividually: false
                    ),
                    height: 200
                )
            }
        }
    }

    static let everythingForEachRating: [EverythingForOneRating] = [
        EverythingForOneRating(
            time: Date().addingTimeInterval(-2 * 60 * 60),
            option: .fourPlus
        ),
        EverythingForOneRating(
            time: Date().addingTimeInterval(-1 * 60 * 60),
            option: .plus
        ),
    ]

    static let everythingForEachTimedNote: [EverythingForOneTimedNote] = [
        EverythingForOneTimedNote(
            time: Date().addingTimeInterval(-2 * 60 * 60),
            color: .blue
        ),
        EverythingForOneTimedNote(
            time: Date().addingTimeInterval(-1 * 60 * 60),
            color: .green
        ),
    ]

    static let substanceGroups: [SubstanceIngestionGroup] = [
        SubstanceIngestionGroup(
            substanceName: "MDMA",
            color: .blue,
            routeMinInfos: [
                RouteMinInfo(
                    route: .oral,
                    ingestions: [
                        IngestionMinInfo(
                            dose: 100,
                            time: .now.addingTimeInterval(-2 * 60 * 60),
                            onsetDelayInHours: 0
                        ),
                        IngestionMinInfo(
                            dose: 50,
                            time: .now,
                            onsetDelayInHours: 0
                        ),
                    ]
                ),
            ]
        ),
        SubstanceIngestionGroup(
            substanceName: "LSD",
            color: .blue,
            routeMinInfos: [
                RouteMinInfo(route: .oral, ingestions: [
                    IngestionMinInfo(
                        dose: 100,
                        time: .now.addingTimeInterval(-4 * 60 * 60),
                        onsetDelayInHours: 0
                    ),
                ]),
            ]
        ),
    ]
}
