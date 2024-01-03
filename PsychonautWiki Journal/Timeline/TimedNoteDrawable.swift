// Copyright (c) 2023. Isaak Hanimann.
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

import SwiftUI

struct TimedNoteDrawable {
    let distanceFromStart: TimeInterval

    private let color: SubstanceColor

    init(
        startGraph: Date,
        time: Date,
        color: SubstanceColor
    ) {
        self.color = color
        distanceFromStart = time.timeIntervalSinceReferenceDate - startGraph.timeIntervalSinceReferenceDate
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        lineWidth: Double
    ) {
        let halfLineWidth = lineWidth / 2
        let x = (distanceFromStart * pixelsPerSec) + halfLineWidth
        var path = Path()
        path.move(to: CGPoint(x: x, y: height))
        path.addLine(to: CGPoint(x: x, y: 0))
        context.stroke(
            path,
            with: .color(color.swiftUIColor),
            style: StrokeStyle.getTimedNoteStokeStyle()
        )
    }
}
