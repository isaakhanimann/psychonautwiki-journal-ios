//
//  OnsetComeupTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct OnsetComeupTimeline : TimelineDrawable {
    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        drawTimeLine(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
        drawTimeLineShape(context: context, height: height, startX: startX, pixelsPerSec: pixelsPerSec, color: color, lineWidth: lineWidth)
    }

    let onset: FullDurationRange
    let comeup: FullDurationRange

    var width: TimeInterval {
        onset.max + comeup.max
    }

    private func drawTimeLine(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        let weight = 0.5
        let minHeight = lineWidth/2
        let maxHeight = height - minHeight
        let onsetEndX = startX + (onset.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        let comeupEndX = onsetEndX + (comeup.interpolateAtValueInSeconds(weight: weight) * pixelsPerSec)
        var path = Path()
        path.move(to: CGPoint(x: startX, y: maxHeight-2*lineWidth))
        path.addLine(to: CGPoint(x: startX, y: maxHeight))
        path.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
        path.addLine(to: CGPoint(x: comeupEndX, y: minHeight))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }

    private func drawTimeLineShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var path = Path()
        let onsetStartMinX = startX + (onset.min * pixelsPerSec)
        let comeupEndMinX = onsetStartMinX + (comeup.min * pixelsPerSec)
        let onsetStartMaxX = startX + (onset.max * pixelsPerSec)
        let comeupEndMaxX =
        onsetStartMaxX + (comeup.max * pixelsPerSec)
        path.move(to: CGPoint(x: onsetStartMinX, y: height))
        path.addLine(to: CGPoint(x: comeupEndMinX, y: 0))
        path.addLine(to: CGPoint(x: comeupEndMaxX, y: 0))
        path.addLine(to: CGPoint(x: onsetStartMaxX, y: height))
        path.closeSubpath()
        context.fill(path, with: .color(color.opacity(shapeOpacity)))
    }
}

extension RoaDuration {
    func toOnsetComeupTimeline() -> OnsetComeupTimeline? {
        if let fullOnset = onset?.maybeFullDurationRange,
           let fullComeup = comeup?.maybeFullDurationRange {
            return OnsetComeupTimeline(
                onset: fullOnset,
                comeup: fullComeup
            )
        } else {
            return nil
        }
    }
}
