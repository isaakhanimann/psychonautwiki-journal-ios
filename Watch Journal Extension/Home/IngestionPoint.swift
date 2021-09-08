import SwiftUI

struct IngestionPoint: View {

    let angle: Angle
    let circleSize: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let (xPosition, yPosition) = angle.getCartesianCoordinates(with: radius)

            Circle()
                .fill()
                .frame(width: circleSize, height: circleSize)
                .position(
                    x: xPosition + radius,
                    y: -yPosition + radius
                )
                .foregroundColor(color)
        }
    }
}

struct IngestionPoint_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width, geometry.size.height)
            IngestionPoint(
                angle: .degrees(0),
                circleSize: 10,
                color: .red
            )
            .frame(width: squareSize, height: squareSize)
            .padding(10)
        }

    }
}
