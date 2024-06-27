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
    let onset: FullDurationRange
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
        var top = lineWidth / 2
        if normalizedHeight < 1 {
            top = ((1 - normalizedHeight) * heightBetween) + (lineWidth / 2)
        }
        let bottom = height - lineWidth / 2
        context.drawDot(x: startX, bottomY: bottom, color: color)
        let onsetWeight = 0.5
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateLinearly(at: onsetWeight)) * pixelsPerSec
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: bottom))
        path0.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        let totalX = total.interpolateLinearly(at: totalWeight) * pixelsPerSec
        let topPointX = onsetEndX + (total.interpolateLinearly(at: totalWeight) - onset.interpolateLinearly(at: onsetWeight)) / 2 * pixelsPerSec
        var path1 = Path()
        path1.move(to: CGPoint(x: onsetEndX, y: bottom))
        path1.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetEndX,
            endX: topPointX,
            endY: top
        )
        let totalEndX = startX + onsetDelayInSeconds * pixelsPerSec + totalX
        path1.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: topPointX,
            startY: top,
            endX: totalEndX,
            endY: bottom
        )
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
        path0.addPath(path1)
        path0.addLine(to: CGPoint(x: totalEndX, y: height))
        path0.addLine(to: CGPoint(x: startX, y: height))
        path0.closeSubpath()
        context.fill(path0, with: .color(color.opacity(shapeOpacity)))
    }

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }
}

extension RoaDuration {
    func toOnsetTotalTimeline(
        totalWeight: Double,
        nonNormalizedHeight: Double,
        nonNormalizedMaxOfRoute: Double,
        areSubstanceHeightsIndependent: Bool,
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> OnsetTotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange, let fullOnset = onset?.maybeFullDurationRange {
            return OnsetTotalTimeline(
                onset: fullOnset,
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
