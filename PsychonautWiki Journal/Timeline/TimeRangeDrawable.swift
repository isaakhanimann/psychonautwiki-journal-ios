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
        let verticalLineWidth: CGFloat = 5
        let horizontalLineWidth: CGFloat = 10
        let startX = startInSeconds * pixelsPerSec
        let endX = endInSeconds * pixelsPerSec
        let lineHeight: CGFloat = 40
        let horizontalLineHeight = lineHeight/2

        var firstVerticalLine = Path()
        firstVerticalLine.move(to: CGPoint(x: startX, y: height))
        firstVerticalLine.addLine(to: CGPoint(x: startX, y: height - lineHeight))
        context.stroke(firstVerticalLine, with: .color(color.swiftUIColor), style: StrokeStyle.getNormal(lineWidth: verticalLineWidth))

        var horizontalLine = Path()
        horizontalLine.move(to: CGPoint(x: startX, y: height - horizontalLineHeight))
        horizontalLine.addLine(to: CGPoint(x: endX, y: height - horizontalLineHeight))
        context.stroke(horizontalLine, with: .color(color.swiftUIColor), style: StrokeStyle(lineWidth: horizontalLineWidth))

        var secondVerticalLine = Path()
        secondVerticalLine.move(to: CGPoint(x: endX, y: height))
        secondVerticalLine.addLine(to: CGPoint(x: endX, y: height - lineHeight))
        context.stroke(secondVerticalLine, with: .color(color.swiftUIColor), style: StrokeStyle.getNormal(lineWidth: verticalLineWidth))
    }
}
