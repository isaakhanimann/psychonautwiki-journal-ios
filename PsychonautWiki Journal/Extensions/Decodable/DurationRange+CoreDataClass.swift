import Foundation
import CoreData

public class DurationRange: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case min, max, units
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

        assert(minValue <= maxValue)

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
            fatalError("Unknown duration unit \(unitSymbol)")
        }

        let min = Measurement(value: minValue, unit: unit)
        let max = Measurement(value: maxValue, unit: unit)

        self.minSec = min.converted(to: .seconds).value
        self.maxSec = max.converted(to: .seconds).value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("seconds", forKey: .units)
        try container.encode(minSec, forKey: .min)
        try container.encode(maxSec, forKey: .max)
    }
}
