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

    enum Units: String, CaseIterable {
        case seconds, minutes, hours, days
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
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
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.units = validUnits.rawValue
        self.min = minValue
        self.max = maxValue
    }
}
