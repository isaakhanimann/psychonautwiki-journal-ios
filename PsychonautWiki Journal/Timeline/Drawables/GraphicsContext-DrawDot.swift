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

import SwiftUI

extension GraphicsContext {
    func drawDot(x: Double, bottomY: Double, color: Color) {
        let dotRadius: CGFloat = 6
        let borderColor = Color.primary
        let borderWidth: CGFloat = 3
        stroke(
            Path(ellipseIn: CGRect(x: x-dotRadius-borderWidth/2, y: bottomY-dotRadius-borderWidth/2, width: dotRadius*2+borderWidth, height: dotRadius*2+borderWidth)),
            with: .color(borderColor),
            lineWidth: borderWidth
        )
        let dotWidth = dotRadius*2
        fill(
            Path(ellipseIn: CGRect(x: x-dotRadius, y: bottomY-dotRadius, width: dotWidth, height: dotWidth)),
            with: .color(color)
        )
    }
}
