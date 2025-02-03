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

    let areSubstanceHeightsIndependent: Bool

    init(
        onset: FullDurationRange,
        comeup: FullDurationRange,
        peak: FullDurationRange,
        offset: FullDurationRange,
        weightedLines: [WeightedLine],
        graphStartTime: Date,
        areSubstanceHeightsIndependent: Bool
    ) {
        let rangeLineSegments = weightedLines.flatMap { weightedLine in
            FullCumulativeTimelines.getRangeLineSegments(
                graphStartTime: graphStartTime,
                weightedLine: weightedLine,
                onset: onset,
                comeup: comeup,
                peak: peak,
                offset: offset
            )
        }
        self.areSubstanceHeightsIndependent = areSubstanceHeightsIndependent
        let weightedRelatives = weightedLines.filter { $0.endTime == nil }.map { weightedLine in
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
        } + rangeLineSegments
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
        let maxPointHeight = finalPoints.map({$0.y}).max() ?? 1
        let nonNormalizedMax = areSubstanceHeightsIndependent ? maxPointHeight : nonNormalizedOverallMax
        let firstHeightInPx = firstPoint.y/nonNormalizedMax * heightBetween + paddingBottom
        path.move(to: CGPoint(x: firstPoint.x * pixelsPerSec, y: height - firstHeightInPx))
        for point in finalPoints.dropFirst() {
            let heightInPx = point.y/nonNormalizedMax * heightBetween + paddingBottom
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
            let pointHeight = point.y/nonNormalizedMax * heightBetween + paddingBottom
            context.drawDot(
                x: point.x * pixelsPerSec,
                bottomY: height - pointHeight,
                color: color
            )
        }
    }

    private static func getRangeLineSegments(
        graphStartTime: Date,
        weightedLine: WeightedLine,
        onset: FullDurationRange,
        comeup: FullDurationRange,
        peak: FullDurationRange,
        offset: FullDurationRange
    )-> [LineSegment] {
        let points = FullCumulativeTimelines.getSamplePointsFrom(
            graphStartTime: graphStartTime,
            weightedLine: weightedLine,
            onset: onset,
            comeup: comeup,
            peak: peak,
            offset: offset
        )
        let lineSegments = FullCumulativeTimelines.getLineSegments(points: points)

        return lineSegments
    }

    static func getSamplePointsFrom(
            graphStartTime: Date,
            weightedLine: WeightedLine,
            onset: FullDurationRange,
            comeup: FullDurationRange,
            peak: FullDurationRange,
            offset: FullDurationRange
    )-> [Point] {
        guard let endTime = weightedLine.endTime else {
            return []
        }
        let startX = graphStartTime.distance(to: weightedLine.startTime)
        let endX = graphStartTime.distance(to: endTime)
        let rangeInSeconds = endX - startX
        let onsetInSeconds = onset.interpolateLinearly(at: 0.5)
        let comeupInSeconds = comeup.interpolateLinearly(at: 0.5)

        var horizontalWeightToUse = 0.5
        if (rangeInSeconds < peak.min) {
            // if the range is short enough we use the same duration as for point ingestion
            horizontalWeightToUse = weightedLine.horizontalWeight
        }
        let peakInSeconds = peak.interpolateLinearly(at: horizontalWeightToUse)
        let offsetInSeconds = offset.interpolateLinearly(at: horizontalWeightToUse)

        let points = FullCumulativeTimelines.getSamplePoints(
            startX: startX,
            endX: endX,
            hMax: weightedLine.strengthRelativeToCommonDose,
            onset: onsetInSeconds,
            comeup: comeupInSeconds,
            peak: peakInSeconds,
            offset: offsetInSeconds
        )
        return points
    }

    static func getLineSegments(points: [Point]) -> [LineSegment] {
        if points.isEmpty {
            return []
        }
        var result: [LineSegment] = []
        var previousPoint = points.first!
        for currentPoint in points.dropFirst() {
            result.append(
                LineSegment(
                    start: previousPoint,
                    end: currentPoint
                )
            )
            previousPoint = currentPoint
        }
        return result
    }

    static func getSamplePoints(
        startX: TimeInterval,
        endX: TimeInterval,
        hMax: Double,
        onset: TimeInterval,
        comeup: TimeInterval,
        peak: TimeInterval,
        offset: TimeInterval
    ) -> [Point] {
        if startX > endX {
            return []
        }
        let numberOfSteps = 30
        let startSampleRange = startX + onset
        let endSampleRange = endX + onset + comeup + peak + offset
        let stepSize = (endSampleRange - startSampleRange) / Double(numberOfSteps)

        let points = (1..<numberOfSteps).map { step in
            let x = startSampleRange + Double(step) * stepSize
            let height = calculateExpression(
                x: x,
                startX: startX,
                endX: endX,
                hMax: hMax,
                onset: onset,
                comeup: comeup,
                peak: peak,
                offset: offset
            )
            return Point(x: x, y: height)
        }
        let firstPoint = Point(x: startSampleRange, y: 0)
        let lastPoint = Point(x: endSampleRange, y: 0)

        return [firstPoint] + points + [lastPoint]
    }

    private static func calculateExpression(
        x: Double,
        startX: Double,
        endX: Double,
        hMax: Double,
        onset: Double,
        comeup: Double,
        peak: Double,
        offset: Double
    ) -> Double {
        let term1 = 2 * comeup * offset * (
            min(endX, max(startX, -comeup - onset + x)) -
            min(endX, max(startX, -comeup - onset - peak + x))
        )

        let term2 = 2 * comeup * (
            min(endX, max(startX, -comeup - onset - peak + x)) -
            min(endX, max(startX, -comeup - offset - onset - peak + x))
        ) * (comeup + offset + onset + peak - x)

        let term3 = comeup * (
            pow(min(endX, max(startX, -comeup - onset - peak + x)), 2) -
            pow(min(endX, max(startX, -comeup - offset - onset - peak + x)), 2)
        )

        let term4 = 2 * offset * (onset - x) * (
            -min(endX, max(startX, -onset + x)) +
             min(endX, max(startX, -comeup - onset + x))
        )

        let term5 = offset * (
            -pow(min(endX, max(startX, -onset + x)), 2) +
             pow(min(endX, max(startX, -comeup - onset + x)), 2)
        )

        let numerator = 0.5 * hMax * (term1 + term2 + term3 + term4 + term5)
        let denominator = comeup * offset * (endX - startX)

        return numerator / denominator
    }
}

extension RoaDuration {
    func toFullCumulativeTimeline(
        weightedLines: [WeightedLine],
        graphStartTime: Date,
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
                areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
            )
        } else {
            return nil
        }
    }
}

let shapeOpacity = 0.2

// swiftlint:enable identifier_name function_body_length
