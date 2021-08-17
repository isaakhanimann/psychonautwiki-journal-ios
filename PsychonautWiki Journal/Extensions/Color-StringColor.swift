import SwiftUI

extension Color {

    static func from(ingestionColor: Ingestion.IngestionColor) -> Color {
        switch ingestionColor {
        case .blue:
            return Color.blue
        case .gray:
            return Color.gray
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
