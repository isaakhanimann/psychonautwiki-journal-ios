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

    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let peakWeight: Double
    let verticalWeight: Double
    let onsetDelayInHours: Double
    let ingestionTimeRelativeToStartInSeconds: TimeInterval

    var endOfLineRelativeToStartInSeconds: TimeInterval {
        ingestionTimeRelativeToStartInSeconds + onsetDelayInSeconds + onset.max + comeup.max + peak.max
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let startX = ingestionTimeRelativeToStartInSeconds*pixelsPerSec
        let weight = 0.5
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = (1-verticalWeight) * height
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateLinearly(at: weight)) * pixelsPerSec
        let comeupEndX = onsetEndX + (comeup.interpolateLinearly(at: weight) * pixelsPerSec)
        let peakEndX = comeupEndX + (peak.interpolateLinearly(at: peakWeight) * pixelsPerSec)
        var path = Path()
        path.move(to: CGPoint(x: startX, y: bottom))
        path.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        path.addLine(to: CGPoint(x: comeupEndX, y: top))
        path.addLine(to: CGPoint(x: peakEndX, y: top))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }


    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }
}

extension RoaDuration {
    func toOnsetComeupPeakTimeline(
        peakWeight: Double,
        verticalWeight: Double,
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> OnsetComeupPeakTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange,
           let fullPeak = peak?.maybeFullDurationRange {
            return OnsetComeupPeakTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                peak: fullPeak,
                peakWeight: peakWeight,
                verticalWeight: verticalWeight,
                onsetDelayInHours: onsetDelayInHours,
                ingestionTimeRelativeToStartInSeconds: ingestionTimeRelativeToStartInSeconds
            )
        } else {
            return nil
        }
    }
}

