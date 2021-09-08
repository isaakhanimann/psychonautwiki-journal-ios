import SwiftUI

struct ClockHand: View {

    let angle: Angle
    let ringLength: CGFloat
    let thinLength: CGFloat
    let thickLength: CGFloat

    var body: some View {
        ZStack {
            HandShape(angle: angle, startRadius: ringLength, length: thinLength)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            HandShape(angle: angle, startRadius: thinLength, length: thickLength)
                .stroke(Color.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
        }
    }
}

struct ClockHand_Previews: PreviewProvider {
    static var previews: some View {
        ClockHand(angle: .degrees(0), ringLength: 3, thinLength: 13, thickLength: 50)
    }
}
