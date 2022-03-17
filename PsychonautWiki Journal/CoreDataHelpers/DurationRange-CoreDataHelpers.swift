import Foundation

extension DurationRange {

    var isFullyDefined: Bool {
        guard unitsUnwrapped != nil else {return false}
        guard let minUnwrap = minUnwrapped else {return false}
        guard let maxUnwrap = maxUnwrapped else {return false}
        return minUnwrap <= maxUnwrap
    }

    var unitsUnwrapped: Units? {
        Units(rawValue: units ?? "Unknown")
    }

    var minUnwrapped: Double? {
        min == 0 ? nil : min
    }

    var maxUnwrapped: Double? {
        max == 0 ? nil : max
    }

    var minSec: Double? {
        convertToSec(value: minUnwrapped)
    }

    var maxSec: Double? {
        convertToSec(value: maxUnwrapped)
    }

    var displayString: String? {
        guard minUnwrapped != nil || maxUnwrapped != nil else {return nil}
        let min = minUnwrapped?.formatted() ?? ".."
        let max = maxUnwrapped?.formatted() ?? ".."
        var result = "\(min)-\(max)"
        guard let unitsUnwrapped = unitsUnwrapped else {return nil}
        switch unitsUnwrapped {
        case .seconds:
            result += "s"
        case .minutes:
            result += "m"
        case .hours:
            result += "h"
        case .days:
            result += "d"
        }
        return result
    }

    private func convertToSec(value: Double?) -> Double? {
        guard var convert = value else {return nil}
        var unit: UnitDuration
        switch unitsUnwrapped {
        case .seconds:
            unit = UnitDuration.seconds
        case .minutes:
            unit = UnitDuration.minutes
        case .hours:
            unit = UnitDuration.hours
        case .days:
            convert *= 24
            unit = UnitDuration.hours
        case .none:
            return nil
        }
        return Measurement(value: convert, unit: unit).converted(to: .seconds).value
    }

    func oneValue(at valueFrom0To1: Double) -> Double? {
        guard let minU = minSec else {return nil}
        guard let maxU = maxSec else {return nil}
        assert(valueFrom0To1 >= 0 && valueFrom0To1 <= 1)
        let difference = maxU - minU
        return minU + valueFrom0To1 * difference
    }
}
