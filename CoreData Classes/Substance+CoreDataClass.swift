import Foundation
import CoreData

public class Substance: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case effects
        case roas
        case category = "class"
        case tolerance
        case addictionPotential
        case toxicity
        case crossTolerances
        case uncertainInteractions
        case unsafeInteractions
        case dangerousInteractions
    }

    struct DecodedInteraction: Decodable {
        var name: String
    }

    struct DecodedEffect: Decodable {
        var name: String
        var url: URL
    }

    struct DecodedClasses: Decodable {
        var psychoactive: [String]
        var chemical: [String]
    }

    // These variables are intermediately stored
    // such that they can be used in SubstancesFile to create objects and relationships
    var decodedUncertain = [DecodedInteraction]()
    var decodedUnsafe = [DecodedInteraction]()
    var decodedDangerous = [DecodedInteraction]()
    var decodedClasses: DecodedClasses?
    var decodedEffects = [DecodedEffect]()
    var decodedCrossTolerances = [String]()

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.name = try? container.decodeIfPresent(String.self, forKey: .name)
        self.url = try? container.decodeIfPresent(URL.self, forKey: .url)
        self.decodedEffects = (try? container.decodeIfPresent(
            [DecodedEffect].self,
            forKey: .effects
        )) ?? []
        let throwableRoas = try? container.decodeIfPresent(
            [Throwable<Roa>].self,
            forKey: .roas)
        let decodedRoas = throwableRoas?.compactMap { try? $0.result.get() }
        self.roas = Set(decodedRoas ?? []) as NSSet
        self.tolerance = try? container.decodeIfPresent(
            Tolerance.self,
            forKey: .tolerance
        )
        self.addictionPotential = try? container.decodeIfPresent(
            String.self,
            forKey: .addictionPotential
        )
        let toxicities = try? container.decodeIfPresent(
            [String].self,
            forKey: .toxicity
        )
        self.toxicity = toxicities?.first
        self.decodedCrossTolerances = (try? container.decodeIfPresent(
            [String].self,
            forKey: .crossTolerances
        )) ?? []
        self.decodedUncertain = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .uncertainInteractions
        )) ?? []
        self.decodedUnsafe = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .unsafeInteractions
        )) ?? []
        self.decodedDangerous = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .dangerousInteractions
        )) ?? []
        self.decodedClasses = try? container.decodeIfPresent(DecodedClasses.self, forKey: .category)
    }
}
