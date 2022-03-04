import Foundation
import CoreData

public class Substance: NSManagedObject, Decodable {

    private enum CodingKeys: String, CodingKey {
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

    // These variables are intermediately stored
    // such that they can be used in SubstancesFile to create objects and relationships
    var decodedUncertainNames = [String]()
    var decodedUnsafeNames = [String]()
    var decodedDangerousNames = [String]()
    var decodedPsychoactiveNames = [String]()
    var decodedChemicalNames = [String]()
    var decodedEffects = [DecodedEffect]()
    var decodedCrossToleranceNames = [String]()

    static let noClassName = "Miscellaneous"

    enum SubstanceDecodingError: Error {
        case invalidName(String)
    }

    // swiftlint:disable function_body_length
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedName = try container.decode(String.self, forKey: .name)
        if Self.namesOfPsychoactiveClasses.contains(decodedName) {
            throw SubstanceDecodingError.invalidName("\(decodedName) is the name of a psychoactive class")
        }
        if Self.namesOfChemicalClasses.contains(decodedName) {
            throw SubstanceDecodingError.invalidName("\(decodedName) is the name of a chemical class")
        }
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.name = decodedName.capitalizedSubstanceName
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
            self.firstPsychoactiveName = Self.noClassName
            psychoactiveNames.append(Self.noClassName)
        }
        self.decodedPsychoactiveNames = psychoactiveNames
        var chemicalNames = decodedClasses?.chemical.map { name in
            name.validClassName
        } ?? []
        if let firstChemical = chemicalNames.first {
            self.firstChemicalName = firstChemical
        } else {
            self.firstChemicalName = Self.noClassName
            chemicalNames.append(Self.noClassName)
        }
        self.decodedChemicalNames = chemicalNames
    }

    private static let namesOfPsychoactiveClasses: Set = [
        "25x-NBOH",
        "Antidepressants",
        "Dissociatives",
        "Entactogens",
        "Entheogen",
        "Gabapentinoids",
        "Hallucinogens",
        "Opioids",
        "Psychedelics",
        "Sedative",
        "Serotonergic psychedelic",
        "Stimulants",
        "Classical psychedelics"
    ]
    private static let namesOfChemicalClasses: Set = [
        "Arylcyclohexylamines",
        "Barbiturates",
        "Benzodiazepines",
        "Diarylethylamines",
        "Lysergamides",
        "Racetams",
        "Thienodiazepines",
        "Xanthines"
    ]
}

private struct DecodedInteraction: Decodable {
    var name: String
}

struct DecodedEffect: Decodable {
    var name: String
    var url: URL
}

private struct DecodedClasses: Decodable {
    var psychoactive: [String]
    var chemical: [String]

    private enum ClassCodingKeys: String, CodingKey {
        case psychoactive
        case chemical
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ClassCodingKeys.self)
        let psychos = try? container.decodeIfPresent([String].self, forKey: .psychoactive)
        if let psychosUnwrap = psychos, !psychosUnwrap.isEmpty {
            self.psychoactive = psychosUnwrap
        } else {
            self.psychoactive = [Substance.noClassName]
        }
        let chems = try? container.decodeIfPresent([String].self, forKey: .chemical)
        if let chemsUnwrap = chems, !chemsUnwrap.isEmpty {
            self.chemical = chemsUnwrap
        } else {
            self.chemical = [Substance.noClassName]
        }
    }
}
