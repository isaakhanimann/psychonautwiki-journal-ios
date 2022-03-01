import Foundation

extension Effect: Comparable {
    public static func < (lhs: Effect, rhs: Effect) -> Bool {
        lhs.nameUnwrapped < rhs.nameUnwrapped
    }

    var nameUnwrapped: String {
        name ?? "Unknown"
    }
}
