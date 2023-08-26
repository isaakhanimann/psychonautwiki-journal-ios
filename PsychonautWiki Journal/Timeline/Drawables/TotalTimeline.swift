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

struct TotalTimeline: TimelineDrawable {

    let total: FullDurationRange
    let onsetDelayInHours: Double
    let totalWeight: Double
    let verticalWeight: Double
    let ingestionTimeRelativeToStartInSeconds: TimeInterval
    let percentSmoothness: Double = 0.5

    var endOfLineRelativeToStartInSeconds: TimeInterval {
        ingestionTimeRelativeToStartInSeconds + onsetDelayInSeconds + total.max
    }

    var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let startX = ingestionTimeRelativeToStartInSeconds*pixelsPerSec
        let top = (1-verticalWeight)*height
        let bottom = height
        let totalMinX = total.min * pixelsPerSec
        let totalX = total.interpolateLinearly(at: totalWeight) * pixelsPerSec
        context.drawDot(
            startX: startX,
            bottomY: bottom-lineWidth/2,
            dotRadius: 1.5 * lineWidth,
            color: color
        )
        let onsetStartX = startX + (onsetDelayInSeconds * pixelsPerSec)
        if onsetDelayInHours > 0 {
            var filledPath = Path()
            let filledPathY = height - lineWidth/2
            filledPath.move(to: CGPoint(x: startX, y: filledPathY))
            filledPath.addLine(to: CGPoint(x: onsetStartX, y: filledPathY))
            context.stroke(filledPath, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        }
        var dottedPath = Path()
        dottedPath.move(to: CGPoint(x: onsetStartX, y: height))
        dottedPath.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetStartX,
            endX: onsetStartX + (totalMinX / 2),
            endY: top
        )
        dottedPath.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetStartX + (totalMinX / 2),
            startY: top,
            endX: onsetStartX + totalX,
            endY: bottom
        )
        context.stroke(
            dottedPath,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
    }
}

extension RoaDuration {
    func toTotalTimeline(
        totalWeight: Double,
        verticalWeight: Double,
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> TotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange {
            return TotalTimeline(
                total: fullTotal,
                onsetDelayInHours: onsetDelayInHours,
                totalWeight: totalWeight,
                verticalWeight: verticalWeight,
                ingestionTimeRelativeToStartInSeconds: ingestionTimeRelativeToStartInSeconds
            )
        } else {
            return nil
        }
    }
}

extension Path {
    mutating func startSmoothLineTo(
        smoothnessBetween0And1: Double,
        startX: Double,
        startY: Double,
        endX: Double,
        endY: Double
    ) {
        let diff = endX - startX
        let controlX = startX + (diff * smoothnessBetween0And1)
        addQuadCurve(to: CGPoint(x: endX, y: endY), control: CGPoint(x: controlX, y: startY))
    }

    mutating func endSmoothLineTo(
        smoothnessBetween0And1: Double,
        startX: Double,
        endX: Double,
        endY: Double
    ) {
        let diff = endX - startX
        let controlX = endX - (diff * smoothnessBetween0And1)
        addQuadCurve(to: CGPoint(x: endX, y: endY), control: CGPoint(x: controlX, y: endY))
    }
}
