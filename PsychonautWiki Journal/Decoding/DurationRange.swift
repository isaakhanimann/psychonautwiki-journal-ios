import Foundation
import CoreData

struct DurationRange: Decodable {

    let min: Double?
    let max: Double?
    let units: Units

    enum CodingKeys: String, CodingKey {
        case min, max, units
    }

    enum DecodingError: Error {
        case unknownDurationUnit
        case minBiggerThanMax
    }

    enum Units: String, CaseIterable {
        case seconds, minutes, hours, days
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let minValue = try container.decode(Double.self, forKey: .min)
        let maxValue = try container.decode(Double.self, forKey: .max)
        let unitSymbol = try container.decode(String.self, forKey: .units)
        if minValue > maxValue {
            throw DecodingError.minBiggerThanMax
        }
        guard let validUnits = Units(rawValue: unitSymbol) else {
            throw DecodingError.unknownDurationUnit
        }
        self.units = validUnits
        self.min = minValue
        self.max = maxValue
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
}
