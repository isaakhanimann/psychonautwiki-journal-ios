//
//  EffectTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct EffectTimeline: View {

    let timelineModel: TimelineModel
    var height: Double = 200
    private let lineWidth: Double = 5

    var body: some View {
        let halfLineWidth = lineWidth/2
        let labelsHeight: Double = 15
        let spaceBetween: Double = 3
        let linesHeight = height - spaceBetween - labelsHeight
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
                    let shouldDrawCurrentTime = timelineDate > timelineModel.startTime.addingTimeInterval(2*60) && timelineDate < timelineModel.startTime.addingTimeInterval(timelineModel.totalWidth)
                    if shouldDrawCurrentTime {
                        let currentTimeX = ((timelineDate.timeIntervalSinceReferenceDate - timelineModel.startTime.timeIntervalSinceReferenceDate)*pixelsPerSec) + halfLineWidth
                        var path = Path()
                        path.move(to: CGPoint(x: currentTimeX, y: 0))
                        path.addLine(to: CGPoint(x: currentTimeX, y: size.height))
                        context.stroke(path, with: .foreground, lineWidth: 3)
                    }
                }
            }
            .frame(height: linesHeight)
            Spacer().frame(height: spaceBetween)
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
            .frame(height: labelsHeight)
        }
    }
}


struct EffectTimeline_Previews: PreviewProvider {

    static var previews: some View {
        List {
            Section {
                EffectTimeline(
                    timelineModel: TimelineModel(
                        everythingForEachLine: everythingForEachLine
                    ),
                    height: 200
                )
            }
        }
    }

    static let everythingForEachLine: [EverythingForOneLine] = [
        // full
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: DurationRange(min: 30, max: 60, units: .minutes),
                comeup: DurationRange(min: 30, max: 60, units: .minutes),
                peak: DurationRange(min: 2, max: 3, units: .hours),
                offset: DurationRange(min: 1, max: 2, units: .hours),
                total: nil,
                afterglow: nil
            ),
            startTime: Date().addingTimeInterval(-3*60*60),
            horizontalWeight: 0.5,
            verticalWeight: 0.75,
            color: .blue
        ),
        // total
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: nil,
                comeup: nil,
                peak: nil,
                offset: nil,
                total: DurationRange(min: 4, max: 6, units: .hours),
                afterglow: nil
            ),
            startTime: Date().addingTimeInterval(-2*60*60),
            horizontalWeight: 0.5,
            verticalWeight: 0.5,
            color: .orange
        ),
        // onset comeup
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: DurationRange(min: 20, max: 40, units: .minutes),
                comeup: DurationRange(min: 1, max: 2, units: .hours),
                peak: nil,
                offset: nil,
                total: nil,
                afterglow: nil
            ),
            startTime: Date().addingTimeInterval(-2*60*60),
            horizontalWeight: 0.5,
            verticalWeight: 1,
            color: .pink
        ),
        // onset comeup peak total
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: DurationRange(min: 30, max: 60, units: .minutes),
                comeup: DurationRange(min: 1, max: 2, units: .hours),
                peak: DurationRange(min: 1, max: 2, units: .hours),
                offset: nil,
                total: DurationRange(min: 6, max: 8, units: .hours),
                afterglow: nil
            ),
            startTime: Date().addingTimeInterval(-60*60),
            horizontalWeight: 0.5,
            verticalWeight: 0.5,
            color: .green
        ),
        // onset
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: DurationRange(min: 30, max: 60, units: .minutes),
                comeup: nil,
                peak: nil,
                offset: nil,
                total: nil,
                afterglow: nil
            ),
            startTime: Date(),
            horizontalWeight: 0.5,
            verticalWeight: 0.5,
            color: .purple
        ),
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
            startTime: Date().addingTimeInterval(-30*60),
            horizontalWeight: 0.5,
            verticalWeight: 0.75,
            color: .yellow
        ),
        // onset comeup total
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: DurationRange(min: 1, max: 2, units: .hours),
                comeup: DurationRange(min: 1, max: 2, units: .hours),
                peak: nil,
                offset: nil,
                total: DurationRange(min: 6, max: 8, units: .hours),
                afterglow: nil
            ),
            startTime: Date().addingTimeInterval(-45*60),
            horizontalWeight: 0.5,
            verticalWeight: 0.9,
            color: .cyan
        ),
        // onset total
        EverythingForOneLine(
            roaDuration: RoaDuration(
                onset: DurationRange(min: 1, max: 2, units: .hours),
                comeup: nil,
                peak: nil,
                offset: nil,
                total: DurationRange(min: 6, max: 8, units: .hours),
                afterglow: nil
            ),
            startTime: Date().addingTimeInterval(-60*60),
            horizontalWeight: 0.5,
            verticalWeight: 0.3,
            color: .brown
        ),
    ]
}
