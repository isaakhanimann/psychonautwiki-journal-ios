import SwiftUI

enum DoseRangeType {
    case thresh, light, common, strong, heavy, none

    var color: Color {
        switch self {
        case .thresh:
            return Color.blue
        case .light:
            return .green
        case .common:
            return .yellow
        case .strong:
            return  .orange
        case .heavy:
            return .red
        case .none:
            return .primary
        }
    }
}
