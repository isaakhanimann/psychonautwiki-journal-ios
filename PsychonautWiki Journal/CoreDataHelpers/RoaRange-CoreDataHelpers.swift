import Foundation
import CoreData

extension RoaRange {

    var minUnwrapped: Double? {
        min == 0 ? nil : min
    }

    var maxUnwrapped: Double? {
        max == 0 ? nil : max
    }

    var displayString: String? {
        guard minUnwrapped != nil || maxUnwrapped != nil else {return nil}
        let min = minUnwrapped?.cleanString ?? ".."
        let max = maxUnwrapped?.cleanString ?? ".."
        return "\(min)-\(max)"
    }
}
