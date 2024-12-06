// Copyright (c) 2024. Isaak Hanimann.
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

struct TimeRangeDrawable {
    private let color: SubstanceColor
    let startInSeconds: TimeInterval
    let endInSeconds: TimeInterval

    init(color: SubstanceColor, startInSeconds: TimeInterval, endInSeconds: TimeInterval) {
        self.color = color
        self.startInSeconds = startInSeconds
        self.endInSeconds = endInSeconds
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double
    ) {
        var path = Path()
        let lineWidth: CGFloat = 10
        let bottom = height - lineWidth
        let startX = startInSeconds * pixelsPerSec
        let endX = endInSeconds * pixelsPerSec

        path.move(to: CGPoint(x: startX, y: bottom))
        path.addLine(to: CGPoint(x: endX, y: bottom))
        context.stroke(path, with: .color(color.swiftUIColor), style: StrokeStyle.getNormal(lineWidth: lineWidth))
    }
}
