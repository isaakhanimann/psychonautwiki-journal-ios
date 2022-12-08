//
//  NoTimeline.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import Foundation
import SwiftUI

struct NoTimeline: TimelineDrawable {
    var width: TimeInterval {
        30*60
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        var path = Path()
        path.move(to: CGPoint(x: startX, y: height - lineWidth * 2))
        path.addLine(to: CGPoint(x: startX, y: height))
        context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }
}
