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
        if Self.namesThatShouldNotBeParsed.contains(decodedName.lowercased()) {
            throw SubstanceDecodingError.invalidName("\(decodedName) is not a substance")
        }
        if decodedName.lowercased().contains("experience") {
            throw SubstanceDecodingError.invalidName("substance name contains the word experience")
        }
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.name = decodedName.capitalizedIfNotAlready
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
        let toleranceNames = (try? container.decodeIfPresent(
            [String].self,
            forKey: .crossTolerances
        )) ?? []
        self.decodedCrossToleranceNames = toleranceNames.map {$0.capitalizedIfNotAlready}
        let decodedUncertain = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .uncertainInteractions
        )) ?? []
        self.decodedUncertainNames = decodedUncertain.map { dec in
            dec.name.capitalizedIfNotAlready
        }
        let decodedUnsafe = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .unsafeInteractions
        )) ?? []
        self.decodedUnsafeNames = decodedUnsafe.map { dec in
            dec.name.capitalizedIfNotAlready
        }
        let decodedDangerous = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .dangerousInteractions
        )) ?? []
        self.decodedDangerousNames = decodedDangerous.map { dec in
            dec.name.capitalizedIfNotAlready
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

    private static let namesThatShouldNotBeParsed: Set = Set([
        "2C-T-X",
        "2C-X",
        "25X-Nbome",
        "Amphetamine (Disambiguation)",
        "Antihistamine",
        "Antipsychotic",
        "Cannabinoid",
        "Datura (Botany)",
        "Deliriant",
        "Depressant",
        "Dox",
        "Harmala Alkaloid",
        "Hyoscyamus Niger (Botany)",
        "Hypnotic",
        "Iso-LSD",
        "List Of Prodrugs",
        "Mandragora Officinarum (Botany)",
        "Nbx",
        "Nootropic",
        "Phenethylamine (Compound)",
        "Piper Nigrum (Botany)",
        "RIMA",
        "Selective Serotonin Reuptake Inhibitor",
        "Serotonin",
        "Serotonin-Norepinephrine Reuptake Inhibitor",
        "Synthetic Cannabinoid",
        "Tabernanthe Iboga (Botany)",
        "Tryptamine (Compound)",
        "Cake",
        "Inhalants",
        "MAOI"
    ].map({$0.lowercased()}))
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
