//
//  FullTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct FullTimeline: TimelineDrawable {
    var width: TimeInterval {
        onset.max + comeup.max + peak.max + offset.max
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
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
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var path = Path()
        // path over top
        let onsetStartMinX = startX + (onset.min * pixelsPerSec)
        let comeupEndMinX = onsetStartMinX + (comeup.min * pixelsPerSec)
        let peakEndMaxX =
            startX + ((onset.max + comeup.max + peak.max) * pixelsPerSec)
        let offsetEndMaxX =
            peakEndMaxX + (offset.max * pixelsPerSec)
        path.move(to: CGPoint(x: onsetStartMinX, y: height))
        path.addLine(to: CGPoint(x: comeupEndMinX, y: 0))
        path.addLine(to: CGPoint(x: peakEndMaxX, y: 0))
        path.addLine(to: CGPoint(x: offsetEndMaxX, y: height))
        // path bottom back
        let onsetStartMaxX = startX + (onset.max * pixelsPerSec)
        let comeupEndMaxX =
            onsetStartMaxX + (comeup.max * pixelsPerSec)
        let peakEndMinX =
            startX + ((onset.min + comeup.min + peak.min) * pixelsPerSec)
        let offsetEndMinX =
            peakEndMinX + (offset.min * pixelsPerSec)
        path.addLine(to: CGPoint(x: offsetEndMinX, y: height))
        path.addLine(to: CGPoint(x: peakEndMinX, y: 0))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: 0))
        path.addLine(to: CGPoint(x: onsetStartMaxX, y: height))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(0.3)))
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
