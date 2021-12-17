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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let url = try container.decode(URL.self, forKey: .url)
        let throwableRoas = try container.decode(
            [Throwable<Roa>].self,
            forKey: .roas)
        let decodedRoas = throwableRoas.compactMap { try? $0.result.get() }
        if decodedRoas.isEmpty {
            throw SubstanceDecodingError.noRoaFound
        }
        let decodedCategoriesNested = try container.decodeIfPresent(DecodedCategoriesNested.self, forKey: .category)
        let unsafeInteractionsDecoded = try container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .unsafeInteractions
        ) ?? []
        let dangerousInteractionsDecoded = try container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .dangerousInteractions
        ) ?? []
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.name = name
        self.url = url
        self.roas = Set(decodedRoas) as NSSet
        self.unsafeInteractionsDecoded = unsafeInteractionsDecoded
        self.dangerousInteractionsDecoded = dangerousInteractionsDecoded
        self.categoriesDecoded = decodedCategoriesNested?.psychoactive ?? []
    }
}
