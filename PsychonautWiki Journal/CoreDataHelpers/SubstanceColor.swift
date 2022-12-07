import SwiftUI

enum SubstanceColor: String, CaseIterable, Identifiable {
    case blue, brown, cyan, green, indigo, mint, orange, pink, purple, red, teal, yellow

    var id: SubstanceColor {
        self
    }

    var swiftUIColor: Color {
        switch self {
        case .blue:
            return Color.blue
        case .green:
            return Color.green
        case .orange:
            return Color.orange
        case .pink:
            return Color.pink
        case .purple:
            return Color.purple
        case .red:
            return Color.red
        case .yellow:
            return Color.yellow
        case .brown:
            return Color.brown
        case .cyan:
            return Color.cyan
        case .indigo:
            return Color.indigo
        case .mint:
            return Color.mint
        case .teal:
            return Color.teal
        }
    }
}
