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

struct OnsetTotalTimeline: TimelineDrawable {

    var width: TimeInterval {
        onsetDelayInSeconds + total.max
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let total: FullDurationRange
    let onsetDelayInHours: Double
    let totalWeight: Double
    let verticalWeigth: Double
    let percentSmoothness: Double = 0.5

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }

    private func drawTimeLine(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        var top = lineWidth/2
        if verticalWeigth < 1 {
            top = ((1-verticalWeigth)*height) + (lineWidth/2)
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetWeight = 0.5
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateAtValueInSeconds(weight: onsetWeight)) * pixelsPerSec
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: bottom))
        path0.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        let totalX = total.interpolateAtValueInSeconds(weight: totalWeight) * pixelsPerSec
        let topPointX = onsetEndX + (total.interpolateAtValueInSeconds(weight: totalWeight) - onset.interpolateAtValueInSeconds(weight: onsetWeight))/2 * pixelsPerSec
        var path1 = Path()
        path1.move(to: CGPoint(x: onsetEndX, y: bottom))
        path1.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetEndX,
            endX: topPointX,
            endY: top
        )
        path1.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: topPointX,
            startY: top,
            endX: startX + onsetDelayInSeconds*pixelsPerSec + totalX,
            endY: bottom
        )
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
    }

    private func drawTimeLineShape(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let top = (1-verticalWeigth)*height
        let bottom = height
        let onsetEndMinX = startX + (onsetDelayInSeconds + onset.min) * pixelsPerSec
        let onsetWeight = 0.5
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateAtValueInSeconds(weight: onsetWeight)) * pixelsPerSec
        let onsetEndMaxX = startX + (onsetDelayInSeconds + onset.max) * pixelsPerSec
        let totalMinX =
        startX + (onsetDelayInSeconds + total.min) * pixelsPerSec
        let totalMaxX = startX +
        (onsetDelayInSeconds + total.max) * pixelsPerSec
        let topPointX = onsetEndX + (total.interpolateAtValueInSeconds(weight: totalWeight) - onset.interpolateAtValueInSeconds(weight: onsetWeight))/2 * pixelsPerSec
        var path = Path()
        path.move(to: CGPoint(x:onsetEndMinX, y: bottom))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetEndMinX,
            endX: topPointX,
            endY: top
        )
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: topPointX,
            startY: top,
            endX: totalMaxX,
            endY: bottom
        )
        path.addLine(to: CGPoint(x: totalMinX, y: bottom))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: totalMinX,
            endX: topPointX,
            endY: top
        )
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: topPointX,
            startY: top,
            endX: onsetEndMaxX,
            endY: bottom
        )
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetTotalTimeline(totalWeight: Double, verticalWeight: Double, onsetDelayInHours: Double) -> OnsetTotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange, let fullOnset = onset?.maybeFullDurationRange {
            return OnsetTotalTimeline(
                onset: fullOnset,
                total: fullTotal,
                onsetDelayInHours: onsetDelayInHours,
                totalWeight: totalWeight,
                verticalWeigth: verticalWeight
            )
        } else {
            return nil
        }
    }
}
