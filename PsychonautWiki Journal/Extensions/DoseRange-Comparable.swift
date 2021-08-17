import Foundation

extension DoseRange: Comparable {
    public static func < (lhs: DoseRange, rhs: DoseRange) -> Bool {
        lhs.min < rhs.min && lhs.max < rhs.min
    }

    public static func == (lhs: DoseRange, rhs: DoseRange) -> Bool {
        lhs.min == rhs.min && lhs.max == rhs.max
    }
}
