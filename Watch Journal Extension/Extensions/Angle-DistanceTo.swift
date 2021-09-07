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
}
