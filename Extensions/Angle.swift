import SwiftUI

extension Angle {

    func positiveDistanceTo(otherAngle: Angle) -> Angle {
        Angle(degrees: (otherAngle - self).asDoubleBetween0and360)
    }

    var asDoubleBetween0and360: Double {
        var result = fmod(self.degrees, 360)
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
