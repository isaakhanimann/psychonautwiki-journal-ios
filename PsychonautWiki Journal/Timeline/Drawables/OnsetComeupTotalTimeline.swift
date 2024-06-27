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

struct OnsetComeupTotalTimeline: TimelineDrawable {
    let onset: FullDurationRange
    let comeup: FullDurationRange
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

    private let onsetAndComeupWeight = 0.5

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
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateLinearly(at: onsetAndComeupWeight)) * pixelsPerSec
        let comeupEndX = onsetEndX + (comeup.interpolateLinearly(at: onsetAndComeupWeight) * pixelsPerSec)
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: bottom))
        path0.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        path0.addLine(to: CGPoint(x: comeupEndX, y: top))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        var path1 = Path()
        path1.move(to: CGPoint(x: comeupEndX, y: top))
        let offsetEndX = startX + (onsetDelayInSeconds + total.interpolateLinearly(at: totalWeight)) * pixelsPerSec
        path1.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: comeupEndX,
            startY: top,
            endX: offsetEndX,
            endY: bottom
        )
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
        path0.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: comeupEndX,
            startY: top,
            endX: offsetEndX,
            endY: bottom
        )
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
    func toOnsetComeupTotalTimeline(
        totalWeight: Double,
        nonNormalizedHeight: Double,
        nonNormalizedMaxOfRoute: Double,
        areSubstanceHeightsIndependent: Bool,
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> OnsetComeupTotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange,
           let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange {
            return OnsetComeupTotalTimeline(
                onset: fullOnset,
                comeup: fullComeup,
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
