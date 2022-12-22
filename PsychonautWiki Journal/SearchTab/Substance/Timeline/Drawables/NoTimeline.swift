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
        context.drawDot(startX: startX, maxHeight: height, dotRadius: 1.5 * lineWidth, color: color)
    }
}
