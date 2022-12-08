//
//  TimelineModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 07.12.22.
//

import Foundation
import SwiftUI

struct TimelineModel {
    let startTime: Date
    let totalWidth: TimeInterval
    let ingestionDrawables: [IngestionDrawable]
//    let axisDrawable: AxisDrawable

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
        self.totalWidth = drawablesWithoutInsets.map({ draw in
            draw.timelineDrawable?.width ?? 2 * 60 * 60
        }).reduce(0, +)
    }
}

struct IngestionDrawable {
    let color: Color
    let ingestionTime: Date
    let roaDuration: RoaDuration?
    let verticalWeight: Double
    let horizontalWeight: Double
    let distanceFromStart: TimeInterval
    let timelineDrawable: TimelineDrawable?
    var insetTimes = 0

    init(startGraph: Date, color: Color, ingestionTime: Date, roaDuration: RoaDuration?, verticalWeight: Double = 1, horizontalWeight: Double = 0.5) {
        self.distanceFromStart = ingestionTime.timeIntervalSinceReferenceDate - startGraph.timeIntervalSinceReferenceDate
        self.color = color
        self.ingestionTime = ingestionTime
        self.roaDuration = roaDuration
        self.verticalWeight = verticalWeight
        self.horizontalWeight = horizontalWeight
        self.timelineDrawable = roaDuration?.toFullTimeline(horizontalWeight: horizontalWeight)
    }
}

extension RoaDuration {
    func toFullTimeline(horizontalWeight: Double) -> FullTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange,
           let fullPeak = peak?.maybeFullDurationRange,
           let fullOffset = offset?.maybeFullDurationRange
        {
            return FullTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                peak: fullPeak,
                offset: fullOffset,
                horizontalWeight: horizontalWeight
            )
        } else {
            return nil
        }
    }
}

struct FullTimeline: TimelineDrawable {
    var width: TimeInterval {
        onset.max + comeup.max + peak.max + offset.max
    }

    func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let minHeight = lineWidth/2
        let maxHeight = height - minHeight
        var path = Path()
        let onsetAndComeupWeight = 0.5
        let onsetEndX =
        startX + (onset.interpolateAtValueInSeconds(weight: onsetAndComeupWeight) * pixelsPerSec)
        let comeupEndX =
            onsetEndX + (comeup.interpolateAtValueInSeconds(weight: onsetAndComeupWeight) * pixelsPerSec)
        let peakEndX =
            comeupEndX + (peak.interpolateAtValueInSeconds(weight: horizontalWeight) * pixelsPerSec)
        let offsetEndX =
            peakEndX + (offset.interpolateAtValueInSeconds(weight: horizontalWeight) * pixelsPerSec)
        path.move(to: CGPoint(x: startX, y: maxHeight))
        path.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
        path.addLine(to: CGPoint(x: comeupEndX, y: minHeight))
        path.addLine(to: CGPoint(x: peakEndX, y: minHeight))
        path.addLine(to: CGPoint(x: offsetEndX, y: maxHeight))
        context.stroke(path, with: .color(color), lineWidth: lineWidth)
    }

    func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
//        drawScope.drawPath(
//                    path = Path().apply {
//                        // path over top
//                        val onsetStartMinX = startX + (onset.minInSeconds * pixelsPerSec)
//                        val comeupEndMinX = onsetStartMinX + (comeup.minInSeconds * pixelsPerSec)
//                        val peakEndMaxX =
//                            startX + ((onset.maxInSeconds + comeup.maxInSeconds + peak.maxInSeconds) * pixelsPerSec)
//                        val offsetEndMaxX =
//                            peakEndMaxX + (offset.maxInSeconds * pixelsPerSec)
//                        moveTo(onsetStartMinX, height)
//                        lineTo(x = comeupEndMinX, y = 0f)
//                        lineTo(x = peakEndMaxX, y = 0f)
//                        lineTo(x = offsetEndMaxX, y = height)
//                        // path bottom back
//                        val onsetStartMaxX = startX + (onset.maxInSeconds * pixelsPerSec)
//                        val comeupEndMaxX =
//                            onsetStartMaxX + (comeup.maxInSeconds * pixelsPerSec)
//                        val peakEndMinX =
//                            startX + ((onset.minInSeconds + comeup.minInSeconds + peak.minInSeconds) * pixelsPerSec)
//                        val offsetEndMinX =
//                            peakEndMinX + (offset.minInSeconds * pixelsPerSec)
//                        lineTo(x = offsetEndMinX, y = height)
//                        lineTo(x = peakEndMinX, y = 0f)
//                        lineTo(x = comeupEndMaxX, y = 0f)
//                        lineTo(x = onsetStartMaxX, y = height)
//                        close()
//                    },
//                    color = color.copy(alpha = shapeAlpha)
//                )
    }

    func getPeakDurationRangeInSeconds(startDuration: TimeInterval) -> ClosedRange<TimeInterval>? {
        let startRange = startDuration + onset.interpolateAtValueInSeconds(weight: 0.5) + comeup.interpolateAtValueInSeconds(weight: 0.5)
        return startRange...(startRange + peak.interpolateAtValueInSeconds(weight: horizontalWeight))
    }

    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let offset: FullDurationRange
    let horizontalWeight: Double
}

protocol TimelineDrawable {
    var width: TimeInterval {get}

    func drawTimeLine(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    )

    func drawTimeLineShape(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    )

    func getPeakDurationRangeInSeconds(startDuration: TimeInterval) -> ClosedRange<TimeInterval>?
}

struct AxisDrawable {

}
