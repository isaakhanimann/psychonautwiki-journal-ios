//
//  TotalTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct TotalTimeline: TimelineDrawable {

    var width: TimeInterval {
        total.max
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    func getPeakDurationRangeInSeconds(startDuration: TimeInterval) -> ClosedRange<TimeInterval>? {
        return nil
    }

    let total: FullDurationRange
    let totalWeight: Double
    let percentSmoothness: Double = 0.5

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let totalMinX = total.min * pixelsPerSec
        let totalX = total.interpolateAtValueInSeconds(weight: totalWeight) * pixelsPerSec
        var path = Path()
        path.move(to: CGPoint(x: startX, y: height))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX,
            endX: startX + (totalMinX / 2),
            endY: 0
        )
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX + (totalMinX / 2),
            startY: 0,
            endX: startX + totalX,
            endY: height
        )
        context.stroke(
            path,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let totalMinX = total.min * pixelsPerSec
        let totalMaxX = total.max * pixelsPerSec
        var path = Path()
        path.move(to: CGPoint(x: startX + (totalMinX / 2), y: 0))
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX + (totalMinX / 2),
            startY: 0,
            endX: startX + totalMaxX,
            endY: height
        )
        path.addLine(to: CGPoint(x: startX + totalMaxX, y: height))
        // path bottom back
        path.addLine(to: CGPoint(x: startX + totalMinX, y: height))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX + totalMinX,
            endX: startX + (totalMinX / 2),
            endY: 0
        )
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(0.3)))
    }
}

extension RoaDuration {
    func toTotalTimeline(totalWeight: Double) -> TotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange {
            return TotalTimeline(total: fullTotal, totalWeight: totalWeight)
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
