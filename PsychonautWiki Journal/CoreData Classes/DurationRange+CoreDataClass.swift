import Foundation
import CoreData

public class DurationRange: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case min, max, units
    }

    enum DecodingError: Error {
        case unknownDurationUnit
        case minBiggerThanMax
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        var minValue = try container.decode(Double.self, forKey: .min)
        var maxValue = try container.decode(Double.self, forKey: .max)
        let unitSymbol = try container.decode(String.self, forKey: .units)

        if minValue > maxValue {
            throw DecodingError.minBiggerThanMax
        }

        var unit: UnitDuration
        switch unitSymbol {
        case "seconds":
            unit = UnitDuration.seconds
        case "minutes":
            unit = UnitDuration.minutes
        case "hours":
            unit = UnitDuration.hours
        case "days":
            minValue *= 24
            maxValue *= 24
            unit = UnitDuration.hours
        default:
            throw DecodingError.unknownDurationUnit
        }

        let min = Measurement(value: minValue, unit: unit)
        let max = Measurement(value: maxValue, unit: unit)

        self.minSec = min.converted(to: .seconds).value
        self.maxSec = max.converted(to: .seconds).value
    }
}
