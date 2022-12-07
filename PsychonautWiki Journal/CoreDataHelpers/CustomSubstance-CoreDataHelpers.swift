import Foundation

extension CustomSubstance {

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var unitsUnwrapped: String {
        units ?? ""
    }

    var explanationUnwrapped: String {
        explanation ?? ""
    }
}
