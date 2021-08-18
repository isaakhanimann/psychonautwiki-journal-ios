import Foundation
import CoreData

public class DoseRange: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case min, max
    }

    enum DecodingError: Error {
        case minBiggerThanMax
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let min = (try? container.decodeIfPresent(Double.self, forKey: .min)) ?? 0
        let max = (try? container.decodeIfPresent(Double.self, forKey: .max)) ?? 0

        if min > max {
            throw DecodingError.minBiggerThanMax
        }
        self.min = min
        self.max = max
    }
}
