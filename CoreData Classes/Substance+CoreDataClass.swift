import Foundation
import CoreData

public class Substance: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case roas
        case category = "class"
        case unsafeInteractions
        case dangerousInteractions
    }

    struct DecodedInteraction: Decodable {
        var name: String
    }

    struct DecodedCategoriesNested: Decodable {
        var psychoactive: [String]
    }

    var unsafeInteractionsDecoded = [DecodedInteraction]()
    var dangerousInteractionsDecoded = [DecodedInteraction]()

    var categoriesDecoded = [String]()

    enum SubstanceDecodingError: Error {
        case noRoaFound
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(URL.self, forKey: .url)

        let throwableRoas = try container.decode(
            [Throwable<Roa>].self,
            forKey: .roas)
        let decodedRoas = throwableRoas.compactMap { try? $0.result.get() }

        if decodedRoas.isEmpty {
            throw SubstanceDecodingError.noRoaFound
        }
        self.roas = Set(decodedRoas) as NSSet
        let decodedCategoriesNested = try container.decodeIfPresent(DecodedCategoriesNested.self, forKey: .category)
        self.categoriesDecoded = decodedCategoriesNested?.psychoactive ?? []
        self.unsafeInteractionsDecoded = try container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .unsafeInteractions
        ) ?? []
        self.dangerousInteractionsDecoded = try container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .dangerousInteractions
        ) ?? []
    }
}
