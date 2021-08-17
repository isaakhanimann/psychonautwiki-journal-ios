import Foundation
import CoreData

public class SubstancesFile: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case generalInteractions, categories
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.generalInteractions = try container.decode(
            Set<GeneralInteraction>.self,
            forKey: .generalInteractions) as NSSet
        self.categories = try container.decode(Set<Category>.self, forKey: .categories) as NSSet
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(generalInteractionsUnwrapped, forKey: .generalInteractions)
        try container.encode(categoriesUnwrapped, forKey: .categories)
    }
}
