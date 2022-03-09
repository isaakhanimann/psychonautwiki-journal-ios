import SwiftUI

enum IngestionColor: String, CaseIterable {
    case blue, green, orange, pink, purple, red, yellow

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
        }
    }
}
