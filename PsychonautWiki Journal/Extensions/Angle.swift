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

extension Angle {
    func positiveDistanceTo(otherAngle: Angle) -> Angle {
        Angle(degrees: (otherAngle - self).asDoubleBetween0and360)
    }

    var asDoubleBetween0and360: Double {
        var result = fmod(degrees, 360)
        if result < 0 {
            result += 360.0
        }
        return result
    }

    // screen space origin is on the top left
    // the angle self is from the center
    func getCartesianCoordinates(with radius: CGFloat) -> (x: CGFloat, y: CGFloat) {
        let degreesFromRightGoingUpwards = -(self - .degrees(90))
        let ingestionAngleFloat = CGFloat(degreesFromRightGoingUpwards.radians)
        let xPosition = radius * cos(ingestionAngleFloat)
        let yPosition = radius * sin(ingestionAngleFloat)
        return (xPosition, yPosition)
    }
}
