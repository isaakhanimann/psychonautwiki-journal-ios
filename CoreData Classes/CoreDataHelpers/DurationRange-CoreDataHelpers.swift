import Foundation

extension DurationRange {

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
        convertToSec(value: minUnwrapped)
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
