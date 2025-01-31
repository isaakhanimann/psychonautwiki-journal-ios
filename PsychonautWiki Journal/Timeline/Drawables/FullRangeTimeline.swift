// Copyright (c) 2025. Isaak Hanimann.
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

import SwiftUI

struct FullRangeTimeline: TimelineDrawable {
    let onset: FullDurationRange
    let comeup: FullDurationRange
    let peak: FullDurationRange
    let offset: FullDurationRange
    let nonNormalizedMaxOfRoute: Double
    let areSubstanceHeightsIndependent: Bool
    let points: [FullCumulativeTimelines.Point]

    init(
        onset: FullDurationRange,
        comeup: FullDurationRange,
        peak: FullDurationRange,
        offset: FullDurationRange,
        nonNormalizedMaxOfRoute: Double,
        areSubstanceHeightsIndependent: Bool,
        graphStartTime: Date,
        weightedLine: WeightedLine,
        nonNormalizedOverallMax: Double = 1.0
    ) {
        self.onset = onset
        self.comeup = comeup
        self.peak = peak
        self.offset = offset
        self.nonNormalizedMaxOfRoute = nonNormalizedMaxOfRoute
        self.areSubstanceHeightsIndependent = areSubstanceHeightsIndependent
        self.nonNormalizedOverallMax = nonNormalizedOverallMax
        let points = FullCumulativeTimelines.getSamplePointsFrom(
            graphStartTime: graphStartTime,
            weightedLine: weightedLine,
            onset: onset,
            comeup: comeup,
            peak: peak,
            offset: offset
        )
        self.points = points
    }

    var nonNormalizedHeight: Double {
        points.map { $0.y }.max() ?? 1
    }

    var nonNormalizedOverallMax = 1.0
    private var normalizedHeight: Double {
        if areSubstanceHeightsIndependent {
            nonNormalizedHeight/nonNormalizedMaxOfRoute
        } else {
            nonNormalizedHeight/nonNormalizedOverallMax
        }
    }


    var endOfLineRelativeToStartInSeconds: TimeInterval {
        points.last?.x ?? 10
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
        guard let firstPoint = points.first else { return }
        var path = Path()
        let maxPointHeight = points.map({$0.y}).max() ?? 1
        let nonNormalizedMax = areSubstanceHeightsIndependent ? maxPointHeight : nonNormalizedOverallMax
        let firstHeightInPx = firstPoint.y/nonNormalizedMax * heightBetween + paddingBottom
        path.move(to: CGPoint(x: firstPoint.x * pixelsPerSec, y: height - firstHeightInPx))
        for point in points.dropFirst() {
            let heightInPx = point.y/nonNormalizedMax * heightBetween + paddingBottom
            path.addLine(to: CGPoint(x: point.x * pixelsPerSec, y: height - heightInPx))
        }
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        // draw shape
        guard let lastX = points.last?.x else { return }
        path.addLine(to: CGPoint(x: lastX * pixelsPerSec, y: height))
        path.addLine(to: CGPoint(x: firstPoint.x * pixelsPerSec, y: height))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toFullRangeTimeline(
        nonNormalizedMaxOfRoute: Double,
        areSubstanceHeightsIndependent: Bool,
        graphStartTime: Date,
        weightedLine: WeightedLine
    ) -> FullRangeTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange,
           let fullPeak = peak?.maybeFullDurationRange,
           let fullOffset = offset?.maybeFullDurationRange {
            return FullRangeTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                peak: fullPeak,
                offset: fullOffset,
                nonNormalizedMaxOfRoute: nonNormalizedMaxOfRoute,
                areSubstanceHeightsIndependent: areSubstanceHeightsIndependent,
                graphStartTime: graphStartTime,
                weightedLine: weightedLine
            )
        } else {
            return nil
        }
    }
}
