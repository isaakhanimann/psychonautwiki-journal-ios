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

struct OnsetComeupPeakTimeline : TimelineDrawable {
    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let peakWeight: Double
    let verticalWeight: Double

    var width: TimeInterval {
        onset.max + comeup.max + peak.max
    }

    private func drawTimeLine(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let weight = 0.5
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = (1-verticalWeight) * height
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        let comeupEndX = onsetEndX + (comeup.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        let peakEndX = comeupEndX + (peak.interpolateAtValueInSeconds(weight: peakWeight) * pixelsPerSec)
        var path = Path()
        path.move(to: CGPoint(x: startX, y: bottom))
        path.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        path.addLine(to: CGPoint(x: comeupEndX, y: top))
        path.addLine(to: CGPoint(x: peakEndX, y: top))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }

    private func drawTimeLineShape(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let top = ((1-verticalWeight) * height) - lineWidth/2
        let bottom = height
        var path = Path()
        let onsetEndMinX = startX + (onset.min * pixelsPerSec)
        let comeupEndMinX = onsetEndMinX + (comeup.min * pixelsPerSec)
        let onsetEndMaxX = startX + (onset.max * pixelsPerSec)
        let comeupEndMaxX = onsetEndMaxX + (comeup.max * pixelsPerSec)
        let peakEndMaxX = comeupEndMaxX + (peak.max * pixelsPerSec)
        let peakEndMinX = comeupEndMinX + (peak.min * pixelsPerSec)
        let shapeHeight = top + (3 * lineWidth)
        path.move(to: CGPoint(x: onsetEndMinX, y: bottom))
        path.addLine(to: CGPoint(x: comeupEndMinX, y: top))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: top))
        path.addLine(to: CGPoint(x: peakEndMaxX, y: top))
        path.addLine(to: CGPoint(x: peakEndMaxX, y: shapeHeight))
        path.addLine(to: CGPoint(x: peakEndMinX, y: shapeHeight))
        path.addLine(to: CGPoint(x: peakEndMinX, y: top))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: top))
        path.addLine(to: CGPoint(x: onsetEndMaxX, y: bottom))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetComeupPeakTimeline(peakWeight: Double, verticalWeight: Double) -> OnsetComeupPeakTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange,
           let fullPeak = peak?.maybeFullDurationRange {
            return OnsetComeupPeakTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                peak: fullPeak,
                peakWeight: peakWeight,
                verticalWeight: verticalWeight
            )
        } else {
            return nil
        }
    }
}

