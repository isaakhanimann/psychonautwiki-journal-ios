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

    var body: some View {
        let halfLineWidth = lineWidth/2
        VStack(spacing: 0) {
            TimelineView(.everyMinute) { timeline in
                let timelineDate = timeline.date
                Canvas { context, size in
                    let pixelsPerSec = (size.width-halfLineWidth)/timelineModel.totalWidth
                    timelineModel.ingestionDrawables.forEach({ drawable in
                        let startX = (drawable.distanceFromStart * pixelsPerSec) + halfLineWidth
                        drawable.timelineDrawable.drawTimeLineWithShape(
                            context: context,
                            height: size.height,
                            startX: startX,
                            pixelsPerSec: pixelsPerSec,
                            color: drawable.color.swiftUIColor,
                            lineWidth: lineWidth
                        )
                    })
                    timelineModel.ratingDrawables.forEach { ratingDrawable in
                        let x = (ratingDrawable.distanceFromStart * pixelsPerSec) + halfLineWidth
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        let halfHeight = size.height/2
                        let padding: Double = 25
                        path.addLine(to: CGPoint(x: x, y: halfHeight-padding))
                        switch ratingDrawable.option {
                        case .minus, .plusMinus, .plus:
                            context.draw(
                                Text(ratingDrawable.option.stringRepresentation),
                                at: CGPoint(x: x, y: halfHeight),
                                anchor: .center
                            )
                        case .twoPlus, .threePlus, .fourPlus:
                            context.rotate(by: .degrees(90))
                            context.draw(
                                Text(ratingDrawable.option.stringRepresentation),
                                at: CGPoint(x: halfHeight, y: -x-halfLineWidth/2),
                                anchor: .center
                            )
                            context.rotate(by: .degrees(-90))
                        }
                        path.move(to: CGPoint(x: x, y: halfHeight+padding))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(path, with: .foreground, lineWidth: 2)
                    }
                    let shouldDrawCurrentTime = timelineDate > timelineModel.startTime.addingTimeInterval(2*60) && timelineDate < timelineModel.startTime.addingTimeInterval(timelineModel.totalWidth) && isShowingCurrentTime
                    if shouldDrawCurrentTime {
                        let currentTimeX = ((timelineDate.timeIntervalSinceReferenceDate - timelineModel.startTime.timeIntervalSinceReferenceDate)*pixelsPerSec) + halfLineWidth
                        var path = Path()
                        path.move(to: CGPoint(x: currentTimeX, y: 0))
                        path.addLine(to: CGPoint(x: currentTimeX, y: size.height))
                        context.stroke(path, with: .foreground, lineWidth: 3)
                    }
                }
            }
            Spacer().frame(height: spaceToLabels)
            Canvas { context, size in
                let widthInPixels = size.width - halfLineWidth
                let pixelsPerSec = widthInPixels/timelineModel.totalWidth
                let fullHours = timelineModel.axisDrawable.getFullHours(
                    pixelsPerSec: pixelsPerSec,
                    widthInPixels: widthInPixels
                )
                fullHours.forEach { fullHour in
                    context.draw(
                        Text(fullHour.label).font(.caption),
                        at: CGPoint(x: fullHour.distanceFromStart + halfLineWidth, y: size.height/2),
                        anchor: .center
                    )
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }.frame(height: height)
    }
}


struct EffectTimeline_Previews: PreviewProvider {

    static var previews: some View {
        List {
            Section {
                EffectTimeline(
                    timelineModel: TimelineModel(
                        everythingForEachLine: everythingForEachLine,
                        everythingForEachRating: []
                    ),
                    height: 200
                )
            }
        }
    }

    static let everythingForEachRating: [EverythingForOneRating] = [
        EverythingForOneRating(
            time: Date().addingTimeInterval(-2*60*60),
            option: .fourPlus
        ),
        EverythingForOneRating(
            time: Date().addingTimeInterval(-1*60*60),
            option: .plus
        )
    ]

    static let everythingForEachLine: [EverythingForOneLine] = [
//        // full
//        EverythingForOneLine(
//            roaDuration: RoaDuration(
//                onset: DurationRange(min: 30, max: 60, units: .minutes),
//                comeup: DurationRange(min: 30, max: 60, units: .minutes),
//                peak: DurationRange(min: 2, max: 3, units: .hours),
//                offset: DurationRange(min: 1, max: 2, units: .hours),
//                total: nil,
//                afterglow: nil
//            ),
//            onsetDelayInHours: 3,
//            startTime: Date().addingTimeInterval(-3*60*60),
//            horizontalWeight: 0.5,
//            verticalWeight: 0.75,
//            color: .blue
//        ),
//        // total
//        EverythingForOneLine(
//            roaDuration: RoaDuration(
//                onset: nil,
//                comeup: nil,
//                peak: nil,
//                offset: nil,
//                total: DurationRange(min: 4, max: 6, units: .hours),
//                afterglow: nil
//            ),
//            onsetDelayInHours: 3,
//            startTime: Date().addingTimeInterval(-2*60*60),
//            horizontalWeight: 0.5,
//            verticalWeight: 0.5,
//            color: .orange
//        ),
//        // onset comeup
//        EverythingForOneLine(
//            roaDuration: RoaDuration(
//                onset: DurationRange(min: 20, max: 40, units: .minutes),
//                comeup: DurationRange(min: 1, max: 2, units: .hours),
//                peak: nil,
//                offset: nil,
//                total: nil,
//                afterglow: nil
//            ),
//            onsetDelayInHours: 3,
//            startTime: Date().addingTimeInterval(-2*60*60),
//            horizontalWeight: 0.5,
//            verticalWeight: 1,
//            color: .pink
//        ),
//        // onset comeup peak total
//        EverythingForOneLine(
//            roaDuration: RoaDuration(
//                onset: DurationRange(min: 30, max: 60, units: .minutes),
//                comeup: DurationRange(min: 1, max: 2, units: .hours),
//                peak: DurationRange(min: 1, max: 2, units: .hours),
//                offset: nil,
//                total: DurationRange(min: 6, max: 8, units: .hours),
//                afterglow: nil
//            ),
//            onsetDelayInHours: 3,
//            startTime: Date().addingTimeInterval(-60*60),
//            horizontalWeight: 0.5,
//            verticalWeight: 0.5,
//            color: .green
//        ),
//        // onset
//        EverythingForOneLine(
//            roaDuration: RoaDuration(
//                onset: DurationRange(min: 1, max: 3, units: .hours),
//                comeup: nil,
//                peak: nil,
//                offset: nil,
//                total: nil,
//                afterglow: nil
//            ),
//            onsetDelayInHours: 3,
//            startTime: Date(),
//            horizontalWeight: 0.5,
//            verticalWeight: 0.5,
//            color: .purple
//        ),
        // onset comeup peak
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: DurationRange(min: 30, max: 60, units: .minutes),
                comeup: DurationRange(min: 1, max: 2, units: .hours),
                peak: DurationRange(min: 1, max: 2, units: .hours),
                offset: nil,
                total: nil,
                afterglow: nil
            ),
            onsetDelayInHours: 3,
            startTime: Date().addingTimeInterval(-30*60),
            horizontalWeight: 0.5,
            verticalWeight: 0.75,
            color: .yellow
        ),
//        // onset comeup total
//        EverythingForOneLine(
//            roaDuration: RoaDuration(
//                onset: DurationRange(min: 1, max: 2, units: .hours),
//                comeup: DurationRange(min: 1, max: 2, units: .hours),
//                peak: nil,
//                offset: nil,
//                total: DurationRange(min: 6, max: 8, units: .hours),
//                afterglow: nil
//            ),
//            onsetDelayInHours: 3,
//            startTime: Date().addingTimeInterval(-45*60),
//            horizontalWeight: 0.5,
//            verticalWeight: 0.9,
//            color: .cyan
//        ),
//        // onset total
//        EverythingForOneLine(
//            roaDuration: RoaDuration(
//                onset: DurationRange(min: 1, max: 2, units: .hours),
//                comeup: nil,
//                peak: nil,
//                offset: nil,
//                total: DurationRange(min: 6, max: 8, units: .hours),
//                afterglow: nil
//            ),
//            onsetDelayInHours: 3,
//            startTime: Date().addingTimeInterval(-60*60),
//            horizontalWeight: 0.5,
//            verticalWeight: 0.3,
//            color: .brown
//        ),
    ]
}
