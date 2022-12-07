import SwiftUI

enum InteractionType {
    case uncertain, unsafe, dangerous

    var color: Color {
        switch self {
        case .uncertain:
            return Color.yellow
        case .unsafe:
            return Color.orange
        case .dangerous:
            return Color.red
        }
    }

    var dangerCount: Int {
        switch self {
        case .uncertain:
            return 1
        case .unsafe:
            return 2
        case .dangerous:
            return 3
        }
    }
}
