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

    struct IntermediateRepresentation {
        let color: SubstanceColor
        let rangeInSeconds: Range<TimeInterval>

        init(color: SubstanceColor, startInSeconds: TimeInterval, endInSeconds: TimeInterval) {
            self.color = color
            // the range operator crashes if start is after end
            if startInSeconds < endInSeconds {
                self.rangeInSeconds = startInSeconds..<endInSeconds
            } else {
                self.rangeInSeconds = startInSeconds..<startInSeconds + 60*60
            }
        }
    }

    private let color: SubstanceColor
    let startInSeconds: TimeInterval
    let endInSeconds: TimeInterval
    let intersectionCountWithPreviousRanges: Int

    init(color: SubstanceColor, startInSeconds: TimeInterval, endInSeconds: TimeInterval, intersectionCountWithPreviousRanges: Int) {
        self.color = color
        self.startInSeconds = startInSeconds
        self.endInSeconds = endInSeconds
        self.intersectionCountWithPreviousRanges = intersectionCountWithPreviousRanges
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double
    ) {
        let verticalLineWidth: CGFloat = 4
        let horizontalLineWidth: CGFloat = 8
        let startX = startInSeconds * pixelsPerSec
        let endX = endInSeconds * pixelsPerSec
        let minLineHeight: CGFloat = 20
        let offset = CGFloat(integerLiteral: intersectionCountWithPreviousRanges) * horizontalLineWidth
        let horizontalLineHeight = minLineHeight/2 + offset
        let verticalLineHeight = minLineHeight + offset
        let verticalLineTopY = height - verticalLineHeight
        let horizontalLineY = height - horizontalLineHeight

        var firstVerticalLine = Path()
        firstVerticalLine.move(to: CGPoint(x: startX, y: height))
        firstVerticalLine.addLine(to: CGPoint(x: startX, y: verticalLineTopY))
        context.stroke(firstVerticalLine, with: .color(color.swiftUIColor), style: StrokeStyle.getNormal(lineWidth: verticalLineWidth))

        var horizontalLine = Path()
        horizontalLine.move(to: CGPoint(x: startX, y: horizontalLineY))
        horizontalLine.addLine(to: CGPoint(x: endX, y: horizontalLineY))
        context.stroke(horizontalLine, with: .color(color.swiftUIColor), style: StrokeStyle(lineWidth: horizontalLineWidth))

        var secondVerticalLine = Path()
        secondVerticalLine.move(to: CGPoint(x: endX, y: height))
        secondVerticalLine.addLine(to: CGPoint(x: endX, y: verticalLineTopY))
        context.stroke(secondVerticalLine, with: .color(color.swiftUIColor), style: StrokeStyle.getNormal(lineWidth: verticalLineWidth))
    }
}
