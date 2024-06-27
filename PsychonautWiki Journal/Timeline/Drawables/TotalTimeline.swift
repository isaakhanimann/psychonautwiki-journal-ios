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
    let nonNormalizedHeight: Double
    let nonNormalizedMaxOfRoute: Double
    let areSubstanceHeightsIndependent: Bool
    let ingestionTimeRelativeToStartInSeconds: TimeInterval
    let percentSmoothness: Double = 0.5

    var nonNormalizedOverallMax = 1.0
    private var normalizedHeight: Double {
        if areSubstanceHeightsIndependent {
            nonNormalizedHeight/nonNormalizedMaxOfRoute
        } else {
            nonNormalizedHeight/nonNormalizedOverallMax
        }
    }

    var endOfLineRelativeToStartInSeconds: TimeInterval {
        ingestionTimeRelativeToStartInSeconds + onsetDelayInSeconds + total.interpolateLinearly(at: totalWeight)
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
        let halfLineWidth = lineWidth / 2
        let paddingTop = halfLineWidth
        let paddingBottom = halfLineWidth
        let heightBetween = height - paddingTop - paddingBottom
        let startX = ingestionTimeRelativeToStartInSeconds * pixelsPerSec
        let top = (1 - normalizedHeight) * heightBetween + paddingTop
        let totalMinX = total.min * pixelsPerSec
        let totalX = total.interpolateLinearly(at: totalWeight) * pixelsPerSec
        context.drawDot(
            x: startX,
            bottomY: height - lineWidth / 2,
            color: color
        )
        let onsetStartX = startX + (onsetDelayInSeconds * pixelsPerSec)
        var filledPath = Path()
        let filledPathY = height - lineWidth / 2
        filledPath.move(to: CGPoint(x: startX, y: filledPathY))
        filledPath.addLine(to: CGPoint(x: onsetStartX, y: filledPathY))
        if onsetDelayInHours > 0 {
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
        let totalEndX = onsetStartX + totalX
        dottedPath.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetStartX + (totalMinX / 2),
            startY: top,
            endX: totalEndX,
            endY: height - paddingBottom
        )
        context.stroke(
            dottedPath,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
        filledPath.addPath(dottedPath)
        filledPath.addLine(to: CGPoint(x: totalEndX, y: height))
        filledPath.addLine(to: CGPoint(x: startX, y: height))
        filledPath.closeSubpath()
        context.fill(filledPath, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toTotalTimeline(
        totalWeight: Double,
        nonNormalizedHeight: Double,
        nonNormalizedMaxOfRoute: Double,
        areSubstanceHeightsIndependent: Bool,
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> TotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange {
            return TotalTimeline(
                total: fullTotal,
                onsetDelayInHours: onsetDelayInHours,
                totalWeight: totalWeight,
                nonNormalizedHeight: nonNormalizedHeight,
                nonNormalizedMaxOfRoute: nonNormalizedMaxOfRoute,
                areSubstanceHeightsIndependent: areSubstanceHeightsIndependent,
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
