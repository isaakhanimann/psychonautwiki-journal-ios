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

// swiftlint:disable identifier_name function_body_length
struct FullCumulativeTimelines: TimelineDrawable {
    var nonNormalizedHeight: Double {
        finalPoints.map { point in
            point.y
        }.max() ?? 1
    }

    var nonNormalizedOverallMax: Double = 1

    var endOfLineRelativeToStartInSeconds: TimeInterval {
        if let max = finalPoints.map({ $0.x }).max() {
            return max
        } else {
            return 5
        }
    }

    struct FinalPoint {
        let x: TimeInterval
        let y: TimeInterval
        let isIngestionPoint: Bool
    }

    struct WeightedLineRelativeToFirst {
        let startTimeRelativeToGroupInSeconds: TimeInterval
        let horizontalWeight: Double
        let height: Double
        let onsetDelayInHours: Double
    }

    struct Point {
        let x: Double
        let y: Double
    }

    struct LineSegment {
        let start: Point
        let end: Point

        func isInside(x: Double) -> Bool {
            return start.x <= x && x < end.x
        }

        func height(at x: Double) -> Double {
            let divider = end.x - start.x
            guard divider != 0 else { return 0 }
            let m = (end.y - start.y) / divider
            let b = start.y - m * start.x
            return m * x + b
        }
    }

    private let finalPoints: [FinalPoint]

    init(
        onset: FullDurationRange,
        comeup: FullDurationRange,
        peak: FullDurationRange,
        offset: FullDurationRange,
        weightedLines: [WeightedLine],
        graphStartTime: Date,
        nonNormalizedMaxOfRoute: Double,
        areSubstanceHeightsIndependent: Bool
    ) {
        let weightedRelatives = weightedLines.map { weightedLine in
            WeightedLineRelativeToFirst(
                startTimeRelativeToGroupInSeconds: weightedLine.startTime.timeIntervalSince1970 - graphStartTime.timeIntervalSince1970,
                horizontalWeight: weightedLine.horizontalWeight,
                height: weightedLine.strengthRelativeToCommonDose,
                onsetDelayInHours: weightedLine.onsetDelayInHours
            )
        }
        let lineSegments = weightedRelatives.flatMap { weightedRelative in
            var result = [LineSegment]()
            let onsetAndComeupWeight = 0.5
            let onsetEndX = weightedRelative.startTimeRelativeToGroupInSeconds + weightedRelative.onsetDelayInHours * 60 * 60 + onset.interpolateLinearly(at: onsetAndComeupWeight)
            let comeupStartPoint = Point(x: onsetEndX, y: 0)
            let comeupEndX = onsetEndX + comeup.interpolateLinearly(at: onsetAndComeupWeight)
            let peakStartPoint = Point(x: comeupEndX, y: weightedRelative.height)
            result.append(
                LineSegment(
                    start: comeupStartPoint,
                    end: peakStartPoint
                )
            )
            let peakEndX = comeupEndX + (peak.interpolateLinearly(at: weightedRelative.horizontalWeight))
            let peakEndPoint = Point(x: peakEndX, y: weightedRelative.height)
            result.append(
                LineSegment(
                    start: peakStartPoint,
                    end: peakEndPoint
                )
            )
            let offsetEndX = peakEndX + offset.interpolateLinearly(at: weightedRelative.horizontalWeight)
            let offsetEndPoint = Point(x: offsetEndX, y: 0)
            result.append(
                LineSegment(
                    start: peakEndPoint,
                    end: offsetEndPoint
                )
            )
            return result
        }
        let linePoints = Set(lineSegments.flatMap { lineSegment in
            [lineSegment.start.x, lineSegment.end.x]
        }).map { point in FinalPoint(x: point, y: 0, isIngestionPoint: false) }
        let ingestionPoints = weightedRelatives.map { relative in
            FinalPoint(
                x: relative.startTimeRelativeToGroupInSeconds,
                y: 0,
                isIngestionPoint: true
            )
        }
        let pointsToConsider = ingestionPoints + linePoints
        let pointsWithHeight = pointsToConsider.map { finalPoint in
            let x = finalPoint.x
            let sumOfHeights = lineSegments.map { lineSegment in
                if lineSegment.isInside(x: x) {
                    return lineSegment.height(at: x)
                } else {
                    return 0
                }
            }.reduce(0.0, +)
            return FinalPoint(x: x, y: sumOfHeights, isIngestionPoint: finalPoint.isIngestionPoint)
        }
        let sortedPoints = pointsWithHeight.sorted { lhs, rhs in
            lhs.x < rhs.x
        }
        finalPoints = sortedPoints
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
        guard let firstPoint = finalPoints.first else { return }
        var path = Path()
        let firstHeightInPx = firstPoint.y/nonNormalizedOverallMax * heightBetween + paddingBottom
        path.move(to: CGPoint(x: firstPoint.x * pixelsPerSec, y: height - firstHeightInPx))
        for point in finalPoints.dropFirst() {
            let heightInPx = point.y/nonNormalizedOverallMax * heightBetween + paddingBottom
            path.addLine(to: CGPoint(x: point.x * pixelsPerSec, y: height - heightInPx))
        }
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        // draw shape
        guard let lastX = finalPoints.last?.x else { return }
        path.addLine(to: CGPoint(x: lastX * pixelsPerSec, y: height))
        path.addLine(to: CGPoint(x: firstPoint.x * pixelsPerSec, y: height))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
        // draw dots
        for point in finalPoints where point.isIngestionPoint {
            let pointHeight = point.y/nonNormalizedOverallMax * heightBetween + paddingBottom
            context.drawDot(
                x: point.x * pixelsPerSec,
                bottomY: height - pointHeight,
                color: color
            )
        }
    }
}

extension RoaDuration {
    func toFullCumulativeTimeline(
        weightedLines: [WeightedLine],
        graphStartTime: Date,
        nonNormalizedMaxOfRoute: Double,
        areSubstanceHeightsIndependent: Bool
    ) -> FullCumulativeTimelines? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange,
           let fullPeak = peak?.maybeFullDurationRange,
           let fullOffset = offset?.maybeFullDurationRange {
            return FullCumulativeTimelines(
                onset: fullOnset,
                comeup: fullComeup,
                peak: fullPeak,
                offset: fullOffset,
                weightedLines: weightedLines,
                graphStartTime: graphStartTime,
                nonNormalizedMaxOfRoute: nonNormalizedMaxOfRoute,
                areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
            )
        } else {
            return nil
        }
    }
}

let shapeOpacity = 0.2

// swiftlint:enable identifier_name function_body_length
