import Foundation
import CoreData

public class Category: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case name, substances
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.substances = try container.decode(Set<Substance>.self, forKey: .substances) as NSSet
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(sortedSubstancesUnwrapped, forKey: .substances)
    }
}
