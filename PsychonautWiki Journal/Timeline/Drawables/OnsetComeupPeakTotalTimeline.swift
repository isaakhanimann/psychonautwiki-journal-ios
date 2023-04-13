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

struct OnsetComeupPeakTotalTimeline: TimelineDrawable {

    var width: TimeInterval {
        onsetDelayInSeconds + total.max
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
    let onsetDelayInHours: Double

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = (1-verticalWeight) * height
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetAndComeupWeight = 0.5
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateAtValueInSeconds(weight: onsetAndComeupWeight)) * pixelsPerSec
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
        let offsetEndX = startX + (onsetDelayInSeconds + total.interpolateAtValueInSeconds(weight: peakAndTotalWeight)) * pixelsPerSec
        path1.addLine(to: CGPoint(x: offsetEndX, y: bottom))
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        // path over top
        let onsetStartMinX = startX + (onsetDelayInSeconds + onset.min) * pixelsPerSec
        let comeupEndMinX = onsetStartMinX + (comeup.min * pixelsPerSec)
        let peakEndMaxX =
        startX + (onsetDelayInSeconds + onset.max + comeup.max + peak.max) * pixelsPerSec
        let offsetEndMaxX = startX + (onsetDelayInSeconds + total.max) * pixelsPerSec
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
        let onsetStartMaxX = startX + (onsetDelayInSeconds + onset.max) * pixelsPerSec
        let comeupEndMaxX =
        onsetStartMaxX + (comeup.max * pixelsPerSec)
        let peakEndMinX =
        startX + (onsetDelayInSeconds + onset.min + comeup.min + peak.min) * pixelsPerSec
        let offsetEndMinX =
        startX + (onsetDelayInSeconds + total.min) * pixelsPerSec
        path.addLine(to: CGPoint(x: offsetEndMinX, y: bottom))
        path.addLine(to: CGPoint(x: peakEndMinX, y: top))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: top))
        path.addLine(to: CGPoint(x: onsetStartMaxX, y: bottom))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetComeupPeakTotalTimeline(peakAndTotalWeight: Double, verticalWeight: Double, onsetDelayInHours: Double) -> OnsetComeupPeakTotalTimeline? {
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
                verticalWeight: verticalWeight,
                onsetDelayInHours: onsetDelayInHours
            )
        } else {
            return nil
        }
    }
}
