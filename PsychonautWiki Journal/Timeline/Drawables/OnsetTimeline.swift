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

struct OnsetTimeline: TimelineDrawable {
    let nonNormalizedHeight = 1.0

    let onset: FullDurationRange
    let onsetDelayInHours: Double
    let ingestionTimeRelativeToStartInSeconds: TimeInterval

    var nonNormalizedOverallMax = 1.0

    private let onsetAndComeupWeight = 0.5

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }

    var endOfLineRelativeToStartInSeconds: TimeInterval {
        ingestionTimeRelativeToStartInSeconds + onsetDelayInHours * 60 * 60 + onset.interpolateLinearly(at: onsetAndComeupWeight)
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let startX = ingestionTimeRelativeToStartInSeconds * pixelsPerSec
        let minHeight = lineWidth / 2
        let maxHeight = height - minHeight
        context.drawDot(x: startX, bottomY: maxHeight, color: color)
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateLinearly(at: onsetAndComeupWeight)) * pixelsPerSec
        var path = Path()
        path.move(to: CGPoint(x: startX, y: maxHeight))
        path.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }
}

extension RoaDuration {
    func toOnsetTimeline(
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> OnsetTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange {
            return OnsetTimeline(
                onset: fullOnset,
                onsetDelayInHours: onsetDelayInHours,
                ingestionTimeRelativeToStartInSeconds: ingestionTimeRelativeToStartInSeconds
            )
        } else {
            return nil
        }
    }
}
