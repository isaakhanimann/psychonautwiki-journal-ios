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
    var decodedUncertainNames = [String]()
    var decodedUnsafeNames = [String]()
    var decodedDangerousNames = [String]()
    var decodedPsychoactiveNames = [String]()
    var decodedChemicalNames = [String]()
    var decodedEffects = [DecodedEffect]()
    var decodedCrossToleranceNames = [String]()

    let noClassName = "Miscellaneous"

    // swiftlint:disable function_body_length
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
        self.decodedCrossToleranceNames = (try? container.decodeIfPresent(
            [String].self,
            forKey: .crossTolerances
        )) ?? []
        let decodedUncertain = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .uncertainInteractions
        )) ?? []
        self.decodedUncertainNames = decodedUncertain.map { dec in
            dec.name
        }
        let decodedUnsafe = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .unsafeInteractions
        )) ?? []
        self.decodedUnsafeNames = decodedUnsafe.map { dec in
            dec.name
        }
        let decodedDangerous = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .dangerousInteractions
        )) ?? []
        self.decodedDangerousNames = decodedDangerous.map { dec in
            dec.name
        }
        let decodedClasses = try? container.decodeIfPresent(DecodedClasses.self, forKey: .category)
        var psychoactiveNames = decodedClasses?.psychoactive.map { name in
            name.validClassName
        } ?? []
        if let firstPsychoactive = psychoactiveNames.first {
            self.firstPsychoactiveName = firstPsychoactive
        } else {
            self.firstPsychoactiveName = noClassName
            psychoactiveNames.append(noClassName)
        }
        self.decodedPsychoactiveNames = psychoactiveNames
        var chemicalNames = decodedClasses?.chemical.map { name in
            name.validClassName
        } ?? []
        if let firstChemical = chemicalNames.first {
            self.firstChemicalName = firstChemical
        } else {
            self.firstChemicalName = noClassName
            chemicalNames.append(noClassName)
        }
        self.decodedChemicalNames = chemicalNames
    }
}
