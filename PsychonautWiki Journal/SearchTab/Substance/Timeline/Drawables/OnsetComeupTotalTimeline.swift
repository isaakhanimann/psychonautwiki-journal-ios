//
//  OnsetComeupTotalTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct OnsetComeupTotalTimeline: TimelineDrawable {

    var width: TimeInterval {
        total.max
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let comeup: FullDurationRange
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
        var top = lineWidth/2
        if verticalWeight < 1 {
            top = ((1-verticalWeight) * height)+(lineWidth/2)
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetAndComeupWeight = 0.5
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: onsetAndComeupWeight) * pixelsPerSec)
        let comeupEndX = onsetEndX + (comeup.interpolateAtValueInSeconds(weight: onsetAndComeupWeight) * pixelsPerSec)
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: bottom))
        path0.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        path0.addLine(to: CGPoint(x: comeupEndX, y: top))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        var path1 = Path()
        path1.move(to: CGPoint(x: comeupEndX, y: top))
        let offsetEndX = startX + (total.interpolateAtValueInSeconds(weight: totalWeight) * pixelsPerSec)
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
    }

    private func drawTimeLineShape(
        context: GraphicsContext,
        height: Double,
        startX: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let top = (1-verticalWeight) * height
        let bottom = height
        let onsetStartMinX = startX + (onset.min * pixelsPerSec)
        let comeupEndMinX = onsetStartMinX + (comeup.min * pixelsPerSec)
        let offsetEndMaxX = startX + (total.max * pixelsPerSec)
        let onsetStartMaxX = startX + (onset.max * pixelsPerSec)
        let comeupEndMaxX =
        onsetStartMaxX + (comeup.max * pixelsPerSec)
        let offsetEndMinX =
        startX + (total.min * pixelsPerSec)
        var path = Path()
        path.move(to: CGPoint(x: onsetStartMinX, y: bottom))
        path.addLine(to: CGPoint(x: comeupEndMinX, y: top))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: top))
        path.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: comeupEndMaxX,
            startY: top,
            endX: offsetEndMaxX,
            endY: bottom
        )
        path.addLine(to: CGPoint(x: offsetEndMinX, y: height))
        path.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: offsetEndMinX,
            endX: comeupEndMinX,
            endY: top
        )
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: top))
        path.addLine(to: CGPoint(x: onsetStartMaxX, y: bottom))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetComeupTotalTimeline(totalWeight: Double, verticalWeight: Double) -> OnsetComeupTotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange,
           let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange{
            return OnsetComeupTotalTimeline(
                onset: fullOnset,
                comeup: fullComeup,
                total: fullTotal,
                totalWeight: totalWeight,
                verticalWeight: verticalWeight
            )
        } else {
            return nil
        }
    }
}
