import SwiftUI

struct ColorPie: View {

    let pieSegments: [PieSegment]

    init(colors: [Color]) {
        var segments = [PieSegment]()
        let total = Double(colors.count)
        var startAngle = -Double.pi / 2

        for color in colors {
            let amount = .pi * 2 * (1 / total)
            let segment = PieSegment(startAngle: startAngle, amount: amount, color: color)
            segments.append(segment)
            startAngle += amount
        }

        pieSegments = segments
    }

    var body: some View {
        ZStack {
            ForEach(pieSegments) { segment in
                segment
                    .fill(segment.color)
            }
        }
    }
}

struct PieSegment: Shape, Identifiable {
    var startAngle: Double
    var amount: Double
    let color: Color

    // swiftlint:disable identifier_name
    let id = UUID()

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)

        var path = Path()
        path.move(to: center)
        path.addRelativeArc(
            center: center,
            radius: radius,
            startAngle: Angle(radians: startAngle),
            delta: Angle(radians: amount)
        )
        return path
    }
}

struct ColorPie_Previews: PreviewProvider {
    static var previews: some View {
        ColorPie(colors: [Color.blue, .yellow, .red, .blue, .green])
    }
}
