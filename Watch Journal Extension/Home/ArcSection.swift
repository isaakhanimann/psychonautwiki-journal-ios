import SwiftUI

struct ArcSection: View {

    let startAngle: Angle
    let endAngle: Angle
    let startColor: Color
    let endColor: Color
    let lineWidth: CGFloat
    let insetOneSide: CGFloat
    let delta: CGFloat

    init(
        startAngle: Angle,
        endAngle: Angle,
        startColor: Color,
        endColor: Color,
        lineWidth: CGFloat,
        insetOneSide: CGFloat
    ) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.startColor = startColor
        self.endColor = endColor
        self.lineWidth = lineWidth
        self.insetOneSide = insetOneSide
        self.delta = CGFloat(startAngle.positiveDistanceTo(otherAngle: endAngle).degrees) / 360
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
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .padding(insetOneSide)
    }
}

struct TryOut_Previews: PreviewProvider {
    static var previews: some View {
        ArcSection(
            startAngle: .degrees(0),
            endAngle: .degrees(180),
            startColor: .blue,
            endColor: .red,
            lineWidth: 20,
            insetOneSide: 10
        )
    }
}
