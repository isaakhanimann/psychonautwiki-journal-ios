import Foundation
import CoreData

public class DoseRange: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case min, max
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.min = (try? container.decode(Double.self, forKey: .min)) ?? 0
        self.max = (try? container.decode(Double.self, forKey: .max)) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(min, forKey: .min)
        try container.encode(max, forKey: .max)
    }
}
