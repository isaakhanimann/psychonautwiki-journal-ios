import Foundation

extension Tolerance {
    var isAtLeastOneDefined: Bool {
        if let zeroUnwrap = zero, !zeroUnwrap.isEmpty {
            return true
        }
        if let halfUnwrap = half, !halfUnwrap.isEmpty {
            return true
        }
        if let fullUnwrap = full, !fullUnwrap.isEmpty {
            return true
        }
        return false
    }
}
