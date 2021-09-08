import SwiftUI

struct ClockHand: Shape {
    let angle: Angle
    let length: Length

    enum Length {
        case hour, minute
    }

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let startPoint = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: startPoint)

        var handLength: CGFloat
        switch length {
        case .hour:
            handLength = min(rect.width, rect.height)/5
        case .minute:
            handLength = min(rect.width, rect.height)/3
        }

        let (xPosition, yPosition) = angle.getCartesianCoordinates(with: handLength)

        let finalX = rect.midX + xPosition
        let finalY = rect.midY - yPosition // upwards is - and downwards +
        let endPoint = CGPoint(x: finalX, y: finalY)
        path.addLine(to: endPoint)

        return path
    }
}
