import SwiftUI

struct ClockHand: View {

    let angle: Angle
    let thinThickness: CGFloat
    let thickThickness: CGFloat
    let ringLength: CGFloat
    let thinLength: CGFloat
    let thickLength: CGFloat

    var body: some View {
        ZStack {
            HandShape(angle: angle, startRadius: ringLength, length: thinLength)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: thinThickness, lineCap: .round))
            HandShape(angle: angle, startRadius: thinLength, length: thickLength)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: thickThickness, lineCap: .round))
        }
    }
}

struct ClockHand_Previews: PreviewProvider {
    static var previews: some View {
        ClockHand(
            angle: .degrees(0),
            thinThickness: 2,
            thickThickness: 6,
            ringLength: 3,
            thinLength: 13,
            thickLength: 50
        )
    }
}
