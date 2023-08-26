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

    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let total: FullDurationRange
    let peakAndTotalWeight: Double
    let verticalWeight: Double
    let onsetDelayInHours: Double
    let ingestionTimeRelativeToStartInSeconds: TimeInterval

    var endOfLineRelativeToStartInSeconds: TimeInterval {
        ingestionTimeRelativeToStartInSeconds + onsetDelayInSeconds + total.max
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let halfLineWidth = lineWidth/2
        let paddingTop = halfLineWidth
        let paddingBottom = halfLineWidth
        let heightBetween = height-paddingTop-paddingBottom
        let startX = ingestionTimeRelativeToStartInSeconds*pixelsPerSec
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = (1-verticalWeight) * heightBetween
        }
        let bottom = height - paddingTop
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetAndComeupWeight = 0.5
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateLinearly(at: onsetAndComeupWeight)) * pixelsPerSec
        let comeupEndX = onsetEndX + (comeup.interpolateLinearly(at: onsetAndComeupWeight) * pixelsPerSec)
        let peakEndX = comeupEndX + (peak.interpolateLinearly(at: peakAndTotalWeight) * pixelsPerSec)
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: bottom))
        path0.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        path0.addLine(to: CGPoint(x: comeupEndX, y: top))
        path0.addLine(to: CGPoint(x: peakEndX, y: top))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        var path1 = Path()
        path1.move(to: CGPoint(x: peakEndX, y: top))
        let offsetEndX = startX + (onsetDelayInSeconds + total.interpolateLinearly(at: peakAndTotalWeight)) * pixelsPerSec
        path1.addLine(to: CGPoint(x: offsetEndX, y: bottom))
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
        path0.addLine(to: CGPoint(x: offsetEndX, y: bottom))
        path0.addLine(to: CGPoint(x: offsetEndX, y: height))
        path0.addLine(to: CGPoint(x: startX, y: height))
        path0.closeSubpath()
        context.fill(path0, with: .color(color.opacity(shapeOpacity)))
    }

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }
}

extension RoaDuration {
    func toOnsetComeupPeakTotalTimeline(
        peakAndTotalWeight: Double,
        verticalWeight: Double,
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> OnsetComeupPeakTotalTimeline? {
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
                onsetDelayInHours: onsetDelayInHours,
                ingestionTimeRelativeToStartInSeconds: ingestionTimeRelativeToStartInSeconds
            )
        } else {
            return nil
        }
    }
}
