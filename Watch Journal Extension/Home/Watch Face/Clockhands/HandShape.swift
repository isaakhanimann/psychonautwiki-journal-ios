import SwiftUI

struct HandShape: Shape {
    let angle: Angle
    let startRadius: CGFloat
    let length: CGFloat

    func path(in rect: CGRect) -> Path {

        var path = Path()

        let startPoint = HandShape.getCGPoint(of: angle, with: startRadius, in: rect)
        path.move(to: startPoint)

        let endPoint = HandShape.getCGPoint(of: angle, with: startRadius+length, in: rect)
        path.addLine(to: endPoint)

        return path
    }

    static func getCGPoint(of angle: Angle, with radius: CGFloat, in rect: CGRect) -> CGPoint {
        let (xPosition, yPosition) = angle.getCartesianCoordinates(with: radius)

        let finalX = rect.midX + xPosition
        let finalY = rect.midY - yPosition // upwards is - and downwards +
        return CGPoint(x: finalX, y: finalY)
    }
}
