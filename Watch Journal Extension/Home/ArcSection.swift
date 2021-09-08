import SwiftUI

struct ArcSection: View {

    let startAngle: Angle
    let endAngle: Angle
    let startColor: Color
    let endColor: Color
    let lineWidth: CGFloat
    let insetOneSide: CGFloat
    let delta: CGFloat
    let rotateBy: Angle

    init(
        startAngle: Angle,
        endAngle: Angle,
        startColor: Color,
        endColor: Color,
        lineWidth: CGFloat,
        insetOneSide: CGFloat
    ) {
        self.startAngle = .degrees(0)
        let distanceAngle = startAngle.positiveDistanceTo(otherAngle: endAngle)
        self.endAngle = distanceAngle
        self.startColor = startColor
        self.endColor = endColor
        self.lineWidth = lineWidth
        self.insetOneSide = insetOneSide
        self.delta = CGFloat(distanceAngle.asDoubleBetween0and360) / 360
        self.rotateBy = .degrees(-90 + startAngle.asDoubleBetween0and360)
    }

    var body: some View {
        return Circle()
            .trim(from: 0, to: delta)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [startColor, endColor]),
                    center: .center,
                    startAngle: startAngle,
                    endAngle: endAngle
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
            )
            .rotationEffect(rotateBy)
            .padding(insetOneSide)
    }
}

struct TryOut_Previews: PreviewProvider {
    static var previews: some View {
        ArcSection(
            startAngle: .degrees(-20),
            endAngle: .degrees(20),
            startColor: .blue,
            endColor: .red,
            lineWidth: 20,
            insetOneSide: 10
        )
    }
}
