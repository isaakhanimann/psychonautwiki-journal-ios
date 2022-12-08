//
//  OnsetTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct OnsetTimeline : TimelineDrawable {
    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange

    func getPeakDurationRangeInSeconds(startDuration: TimeInterval) -> ClosedRange<TimeInterval>? {
        return nil
    }

    var width: TimeInterval {
        onset.max
    }

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let weight = 0.5
        let minHeight = lineWidth/2
        let maxHeight = height - minHeight
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        var path = Path()
        path.move(to: CGPoint(x: startX, y: maxHeight-2*lineWidth))
        path.addLine(to: CGPoint(x: startX, y: maxHeight))
        path.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var path = Path()
        let onsetEndMinX = startX + (onset.min * pixelsPerSec)
        let onsetEndMaxX = startX + (onset.max * pixelsPerSec)
        let shapeHeight = 3 * lineWidth
        path.move(to: CGPoint(x: onsetEndMinX, y: height))
        path.addLine(to: CGPoint(x: onsetEndMaxX, y: height))
        path.addLine(to: CGPoint(x: onsetEndMaxX, y: height - shapeHeight))
        path.addLine(to: CGPoint(x: onsetEndMinX, y: height - shapeHeight))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetTimeline() -> OnsetTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange {
            return OnsetTimeline(
                onset: fullOnset
            )
        } else {
            return nil
        }
    }
}
