//
//  OnsetTotalTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct OnsetTotalTimeline: TimelineDrawable {

    var width: TimeInterval {
        total.max
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let total: FullDurationRange
    let totalWeight: Double
    let percentSmoothness: Double = 0.5

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let minHeight = lineWidth/2
        let maxHeight = height - minHeight
        context.drawDot(startX: startX, maxHeight: maxHeight, dotRadius: 1.5 * lineWidth, color: color)
        let onsetWeight = 0.5
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: onsetWeight) * pixelsPerSec)
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: maxHeight))
        path0.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        let totalX = total.interpolateAtValueInSeconds(weight: totalWeight) * pixelsPerSec
        var path1 = Path()
        path1.move(to: CGPoint(x: onsetEndX, y: maxHeight))
        path1.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetEndX,
            endX: totalX/2,
            endY: minHeight
        )
        path1.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: totalX/2,
            startY: 0,
            endX: totalX,
            endY: maxHeight
        )
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let onsetEndMinX = startX + (onset.min * pixelsPerSec)
        let onsetEndMaxX = startX + (onset.max * pixelsPerSec)
        let totalX = total.interpolateAtValueInSeconds(weight: totalWeight) * pixelsPerSec
        let totalMinX =
        total.min * pixelsPerSec
        let totalMaxX =
        total.max * pixelsPerSec
        var path = Path()
        path.move(to: CGPoint(x:onsetEndMinX, y: height))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetEndMinX,
            endX: totalX / 2,
            endY: 0
        )
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: totalX / 2,
            startY: 0,
            endX: totalMaxX,
            endY: height
        )
        path.addLine(to: CGPoint(x: totalMinX, y: height))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: totalMinX,
            endX: totalX / 2,
            endY: 0
        )
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: totalX / 2,
            startY: 0,
            endX: onsetEndMaxX,
            endY: height
        )
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetTotalTimeline(totalWeight: Double) -> OnsetTotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange, let fullOnset = onset?.maybeFullDurationRange {
            return OnsetTotalTimeline(onset: fullOnset, total: fullTotal, totalWeight: totalWeight)
        } else {
            return nil
        }
    }
}
