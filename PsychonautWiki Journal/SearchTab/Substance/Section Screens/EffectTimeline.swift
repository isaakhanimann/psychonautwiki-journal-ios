//
//  EffectTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct EffectTimeline: View {

    let timelineModel: TimelineModel
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
                            color: drawable.color,
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
                .frame(height: 200)
            }
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
        }
    }
}
