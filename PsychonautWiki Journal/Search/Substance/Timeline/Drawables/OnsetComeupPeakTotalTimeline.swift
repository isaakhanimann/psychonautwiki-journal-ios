//
//  OnsetComeupPeakTotalTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation

import SwiftUI

struct OnsetComeupPeakTotalTimeline: TimelineDrawable {

    var width: TimeInterval {
        total.max
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let total: FullDurationRange
    let peakAndTotalWeight: Double
    let verticalWeight: Double

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = (1-verticalWeight) * height
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetAndComeupWeight = 0.5
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: onsetAndComeupWeight) * pixelsPerSec)
        let comeupEndX = onsetEndX + (comeup.interpolateAtValueInSeconds(weight: onsetAndComeupWeight) * pixelsPerSec)
        let peakEndX = comeupEndX + (peak.interpolateAtValueInSeconds(weight: peakAndTotalWeight) * pixelsPerSec)
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: bottom))
        path0.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        path0.addLine(to: CGPoint(x: comeupEndX, y: top))
        path0.addLine(to: CGPoint(x: peakEndX, y: top))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        var path1 = Path()
        path1.move(to: CGPoint(x: peakEndX, y: top))
        let offsetEndX = startX + (total.interpolateAtValueInSeconds(weight: peakAndTotalWeight) * pixelsPerSec)
        path1.addLine(to: CGPoint(x: offsetEndX, y: bottom))
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        // path over top
        let onsetStartMinX = startX + (onset.min * pixelsPerSec)
        let comeupEndMinX = onsetStartMinX + (comeup.min * pixelsPerSec)
        let peakEndMaxX =
        startX + ((onset.max + comeup.max + peak.max) * pixelsPerSec)
        let offsetEndMaxX = startX + (total.max * pixelsPerSec)
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = ((1-verticalWeight) * height) - lineWidth/2
        }
        let bottom = height
        var path = Path()
        path.move(to: CGPoint(x: onsetStartMinX, y: bottom))
        path.addLine(to: CGPoint(x: comeupEndMinX, y: top))
        path.addLine(to: CGPoint(x: peakEndMaxX, y: top))
        path.addLine(to: CGPoint(x: offsetEndMaxX, y: bottom))
        // path bottom back
        let onsetStartMaxX = startX + (onset.max * pixelsPerSec)
        let comeupEndMaxX =
        onsetStartMaxX + (comeup.max * pixelsPerSec)
        let peakEndMinX =
        startX + ((onset.min + comeup.min + peak.min) * pixelsPerSec)
        let offsetEndMinX =
        startX + (total.min * pixelsPerSec)
        path.addLine(to: CGPoint(x: offsetEndMinX, y: bottom))
        path.addLine(to: CGPoint(x: peakEndMinX, y: top))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: top))
        path.addLine(to: CGPoint(x: onsetStartMaxX, y: bottom))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetComeupPeakTotalTimeline(peakAndTotalWeight: Double, verticalWeight: Double) -> OnsetComeupPeakTotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange,
           let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange,
           let fullPeak = peak?.maybeFullDurationRange {
            return OnsetComeupPeakTotalTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                peak: fullPeak,
                total: fullTotal,
                peakAndTotalWeight: peakAndTotalWeight,
                verticalWeight: verticalWeight
            )
        } else {
            return nil
        }
    }
}
