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

struct OnsetComeupTimeline : TimelineDrawable {
    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let comeup: FullDurationRange
    let verticalWeight: Double

    var width: TimeInterval {
        onset.max + comeup.max
    }

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let weight = 0.5
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = (1-verticalWeight) * height
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        let comeupEndX = onsetEndX + (comeup.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        var path = Path()
        path.move(to: CGPoint(x: startX, y: bottom))
        path.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        path.addLine(to: CGPoint(x: comeupEndX, y: top))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var path = Path()
        let onsetStartMinX = startX + (onset.min * pixelsPerSec)
        let comeupEndMinX = onsetStartMinX + (comeup.min * pixelsPerSec)
        let onsetStartMaxX = startX + (onset.max * pixelsPerSec)
        let comeupEndMaxX =
        onsetStartMaxX + (comeup.max * pixelsPerSec)
        let bottom = height
        let top = (1-verticalWeight) * height
        path.move(to: CGPoint(x: onsetStartMinX, y: bottom))
        path.addLine(to: CGPoint(x: comeupEndMinX, y: top))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: top))
        path.addLine(to: CGPoint(x: onsetStartMaxX, y: bottom))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetComeupTimeline(verticalWeight: Double) -> OnsetComeupTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange {
            return OnsetComeupTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                verticalWeight: verticalWeight
            )
        } else {
            return nil
        }
    }
}
