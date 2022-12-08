//
//  OnsetComeupPeakTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct OnsetComeupPeakTimeline : TimelineDrawable {
    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let peakWeight: Double

    func getPeakDurationRangeInSeconds(startDuration: TimeInterval) -> ClosedRange<TimeInterval>? {
        let startRange = startDuration + onset.interpolateAtValueInSeconds(weight: 0.5) + comeup.interpolateAtValueInSeconds(weight: 0.5)
        return startRange...(startRange + peak.interpolateAtValueInSeconds(weight: peakWeight))
    }

    var width: TimeInterval {
        onset.max + comeup.max + peak.max
    }

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let weight = 0.5
        let minHeight = lineWidth/2
        let maxHeight = height - minHeight
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        let comeupEndX = onsetEndX + (comeup.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        let peakEndX = comeupEndX + (peak.interpolateAtValueInSeconds(weight: peakWeight) * pixelsPerSec)
        var path = Path()
        path.move(to: CGPoint(x: startX, y: maxHeight))
        path.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
        path.addLine(to: CGPoint(x: comeupEndX, y: minHeight))
        path.addLine(to: CGPoint(x: peakEndX, y: minHeight))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var path = Path()
        let onsetEndMinX = startX + (onset.min * pixelsPerSec)
        let comeupEndMinX = onsetEndMinX + (comeup.min * pixelsPerSec)
        let onsetEndMaxX = startX + (onset.max * pixelsPerSec)
        let comeupEndMaxX = onsetEndMaxX + (comeup.max * pixelsPerSec)
        let peakEndMaxX = comeupEndMaxX + (peak.max * pixelsPerSec)
        let peakEndMinX = comeupEndMinX + (peak.min * pixelsPerSec)
        let shapeHeight = 3 * lineWidth
        path.move(to: CGPoint(x: onsetEndMinX, y: height))
        path.addLine(to: CGPoint(x: comeupEndMinX, y: 0))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: 0))
        path.addLine(to: CGPoint(x: peakEndMaxX, y: 0))
        path.addLine(to: CGPoint(x: peakEndMaxX, y: shapeHeight))
        path.addLine(to: CGPoint(x: peakEndMinX, y: shapeHeight))
        path.addLine(to: CGPoint(x: peakEndMinX, y: 0))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: 0))
        path.addLine(to: CGPoint(x: onsetEndMaxX, y: height))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(0.3)))
    }
}

extension RoaDuration {
    func toOnsetComeupPeakTimeline(peakWeight: Double) -> OnsetComeupPeakTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange,
           let fullPeak = peak?.maybeFullDurationRange {
            return OnsetComeupPeakTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                peak: fullPeak,
                peakWeight: peakWeight
            )
        } else {
            return nil
        }
    }
}

