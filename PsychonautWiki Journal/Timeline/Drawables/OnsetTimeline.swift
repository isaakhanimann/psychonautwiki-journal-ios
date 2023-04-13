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

struct OnsetTimeline : TimelineDrawable {
    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let onsetDelayInHours: Double

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }

    var width: TimeInterval {
        onsetDelayInSeconds + onset.max
    }

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let weight = 0.5
        let minHeight = lineWidth/2
        let maxHeight = height - minHeight
        context.drawDot(startX: startX, bottomY: maxHeight, dotRadius: 1.5 * lineWidth, color: color)
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateAtValueInSeconds(weight: weight)) * pixelsPerSec
        var path = Path()
        path.move(to: CGPoint(x: startX, y: maxHeight))
        path.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var path = Path()
        let onsetEndMinX = startX + (onsetDelayInSeconds + onset.min) * pixelsPerSec
        let onsetEndMaxX = startX + (onsetDelayInSeconds + onset.max) * pixelsPerSec
        let shapeHeight = 3 * lineWidth
        path.move(to: CGPoint(x: onsetEndMinX, y: height))
        path.addLine(to: CGPoint(x: onsetEndMaxX, y: height))
        path.addLine(to: CGPoint(x: onsetEndMaxX, y: height - shapeHeight))
        path.addLine(to: CGPoint(x: onsetEndMinX, y: height - shapeHeight))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetTimeline(onsetDelayInHours: Double) -> OnsetTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange {
            return OnsetTimeline(
                onset: fullOnset,
                onsetDelayInHours: onsetDelayInHours
            )
        } else {
            return nil
        }
    }
}
