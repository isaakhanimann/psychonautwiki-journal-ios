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

struct NoTimeline: TimelineDrawable {

    let onsetDelayInHours: Double

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }

    var width: TimeInterval {
        onsetDelayInSeconds + 5*60*60
    }

    func drawTimeLineWithShape(context: GraphicsContext, height: Double, startX: Double, pixelsPerSec: Double, color: Color, lineWidth: Double) {
        context.drawDot(startX: startX, bottomY: height, dotRadius: 1.5 * lineWidth, color: color)
        if onsetDelayInHours > 0 {
            let maxHeight = height - lineWidth/2
            let onsetEndX = startX + onsetDelayInSeconds * pixelsPerSec
            var path = Path()
            path.move(to: CGPoint(x: startX, y: maxHeight))
            path.addLine(to: CGPoint(x: onsetEndX, y: maxHeight))
            context.stroke(path, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        }
    }
}
