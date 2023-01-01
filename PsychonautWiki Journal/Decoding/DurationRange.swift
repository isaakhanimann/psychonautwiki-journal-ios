import Foundation
import CoreData

struct DurationRange: Codable {

    let min: Double?
    let max: Double?
    let units: Units

    enum Units: String, CaseIterable, Codable {
        case seconds, minutes, hours, days
    }

    var isFullyDefined: Bool {
        guard let minUnwrap = min else {return false}
        guard let maxUnwrap = max else {return false}
        return minUnwrap <= maxUnwrap
    }

    var minSec: Double? {
        convertToSec(value: min)
    }

    var maxSec: Double? {
        convertToSec(value: max)
    }

    var displayString: String? {
        guard min != nil || max != nil else {return nil}
        let min = min?.formatted() ?? ".."
        let max = max?.formatted() ?? ".."
        var result = "\(min)-\(max)"
        switch units {
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
        switch units {
        case .seconds:
            unit = UnitDuration.seconds
        case .minutes:
            unit = UnitDuration.minutes
        case .hours:
            unit = UnitDuration.hours
        case .days:
            convert *= 24
            unit = UnitDuration.hours
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

    var maybeFullDurationRange: FullDurationRange? {
        if let min = minSec, let max = maxSec {
            return FullDurationRange(min: min, max: max)
        } else {
            return nil
        }
    }

}

struct FullDurationRange {
    let min: TimeInterval
    let max: TimeInterval

    func interpolateAtValueInSeconds(weight: Double) -> TimeInterval {
        let diff = max - min
        return min + (diff * weight)
    }
}
