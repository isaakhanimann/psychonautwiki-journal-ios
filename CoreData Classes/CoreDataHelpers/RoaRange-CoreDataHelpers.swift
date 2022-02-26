import Foundation
import CoreData

extension RoaRange {

    var minUnwrapped: Double? {
        min == 0 ? nil : min
    }

    var maxUnwrapped: Double? {
        max == 0 ? nil : max
    }

    var isDefined: Bool {
        minUnwrapped != nil && maxUnwrapped != nil
    }
}
