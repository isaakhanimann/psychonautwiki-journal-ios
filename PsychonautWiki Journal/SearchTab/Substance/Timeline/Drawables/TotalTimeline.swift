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

    let total: FullDurationRange
    let totalWeight: Double
    let verticalWeight: Double
    let percentSmoothness: Double = 0.5

    private func drawTimeLine(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let top = (1-verticalWeight)*height
        let bottom = height
        let totalMinX = total.min * pixelsPerSec
        let totalX = total.interpolateAtValueInSeconds(weight: totalWeight) * pixelsPerSec
        context.drawDot(startX: startX, bottomY: bottom-lineWidth/2, dotRadius: 1.5 * lineWidth, color: color)
        var path = Path()
        path.move(to: CGPoint(x: startX, y: height))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX,
            endX: startX + (totalMinX / 2),
            endY: top
        )
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX + (totalMinX / 2),
            startY: top,
            endX: startX + totalX,
            endY: bottom
        )
        context.stroke(
            path,
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
        let top = (1-verticalWeight)*height
        let bottom = height
        let totalMinX = total.min * pixelsPerSec
        let totalMaxX = total.max * pixelsPerSec
        var path = Path()
        path.move(to: CGPoint(x: startX + (totalMinX / 2), y: top))
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX + (totalMinX / 2),
            startY: top,
            endX: startX + totalMaxX,
            endY: bottom
        )
        path.addLine(to: CGPoint(x: startX + totalMaxX, y: bottom))
        // path bottom back
        path.addLine(to: CGPoint(x: startX + totalMinX, y: bottom))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: startX + totalMinX,
            endX: startX + (totalMinX / 2),
            endY: top
        )
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toTotalTimeline(totalWeight: Double, verticalWeight: Double) -> TotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange {
            return TotalTimeline(
                total: fullTotal,
                totalWeight: totalWeight,
                verticalWeight: verticalWeight
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
