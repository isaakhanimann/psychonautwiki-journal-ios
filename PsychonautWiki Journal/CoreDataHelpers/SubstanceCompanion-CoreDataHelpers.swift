import Foundation

extension SubstanceCompanion {

    var color: SubstanceColor {
        if let text = colorAsText, let color = SubstanceColor(rawValue: text) {
            return color
        } else {
            return SubstanceColor.red
        }
    }

    var substanceNameUnwrapped: String? {
        substanceName ?? "Unknown"
    }
}
