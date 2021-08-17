import Foundation
import CoreData

public class Substance: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case isFavorite
        case roas
        case unsafeSubstanceInteractions
        case unsafeCategoryInteractions
        case unsafeGeneralInteractions
        case dangerousSubstanceInteractions
        case dangerousCategoryInteractions
        case dangerousGeneralInteractions
    }

    var unsafeSubstanceInteractionsDecoded = [String]()
    var unsafeCategoryInteractionsDecoded = [String]()
    var unsafeGeneralInteractionsDecoded = [String]()
    var dangerousSubstanceInteractionsDecoded = [String]()
    var dangerousCategoryInteractionsDecoded = [String]()
    var dangerousGeneralInteractionsDecoded = [String]()

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(URL.self, forKey: .url)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.roas = try container.decode(Set<Roa>.self, forKey: .roas) as NSSet
        self.unsafeSubstanceInteractionsDecoded = try container.decode(
            [String].self,
            forKey: .unsafeSubstanceInteractions
        )
        self.unsafeCategoryInteractionsDecoded = try container.decode(
            [String].self,
            forKey: .unsafeCategoryInteractions
        )
        self.unsafeGeneralInteractionsDecoded = try container.decode(
            [String].self,
            forKey: .unsafeGeneralInteractions
        )
        self.dangerousSubstanceInteractionsDecoded = try container.decode(
            [String].self,
            forKey: .dangerousSubstanceInteractions
        )
        self.dangerousCategoryInteractionsDecoded = try container.decode(
            [String].self,
            forKey: .dangerousCategoryInteractions
        )
        self.dangerousGeneralInteractionsDecoded = try container.decode(
            [String].self,
            forKey: .dangerousGeneralInteractions
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(roasUnwrapped, forKey: .roas)
        try container.encode(
            getArrayOfNames(for: unsafeSubstanceInteractionsUnwrapped),
            forKey: .unsafeSubstanceInteractions
        )
        try container.encode(
            getArrayOfNames(for: unsafeCategoryInteractionsUnwrapped),
            forKey: .unsafeCategoryInteractions
        )
        try container.encode(
            getArrayOfNames(for: unsafeGeneralInteractionsUnwrapped),
            forKey: .unsafeGeneralInteractions
        )

        try container.encode(
            getArrayOfNames(for: dangerousSubstanceInteractionsUnwrapped),
            forKey: .dangerousSubstanceInteractions
        )
        try container.encode(
            getArrayOfNames(for: dangerousCategoryInteractionsUnwrapped),
            forKey: .dangerousCategoryInteractions
        )
        try container.encode(
            getArrayOfNames(for: dangerousGeneralInteractionsUnwrapped),
            forKey: .dangerousGeneralInteractions
        )
    }

    private func getArrayOfNames(for substances: [Substance]) -> [String] {
        substances.map { substance in
            substance.nameUnwrapped
        }
    }

    private func getArrayOfNames(for categories: [Category]) -> [String] {
        categories.map { category in
            category.nameUnwrapped
        }
    }

    private func getArrayOfNames(for generalInteractions: [GeneralInteraction]) -> [String] {
        generalInteractions.map { interaction in
            interaction.nameUnwrapped
        }
    }
}
