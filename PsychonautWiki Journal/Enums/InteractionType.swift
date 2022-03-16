import SwiftUI

enum InteractionType {
    case none, uncertain, unsafe, dangerous

    var color: Color {
        switch self {
        case .uncertain:
            return Color.yellow
        case .unsafe:
            return Color.orange
        case .dangerous:
            return Color.red
        case .none:
            return Color.primary
        }
    }

    var systemImageName: String {
        switch self {
        case .none:
            return "questionmark"
        case .uncertain:
            return "exclamationmark.triangle"
        case .unsafe:
            return "exclamationmark.triangle"
        case .dangerous:
            return "xmark"
        }
    }
}
