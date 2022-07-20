import Foundation
import CoreData

struct Substance: Decodable, Identifiable {
    // swiftlint:disable identifier_name
    var id: String {
        name
    }
    let name: String
    let url: URL
    let roas: [Roa]
    let psychoactiveClasses: [String]
    let chemicalClasses: [String]
    let tolerance: Tolerance?
    let addictionPotential: String?
    let toxicities: [String]
    let crossTolerances: [String]
    let uncertainInteractions: [String]
    let unsafeInteractions: [String]
    let dangerousInteractions: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case url
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

    enum SubstanceDecodingError: Error {
        case invalidName(String)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // TODO: remove substances that contain word experiences
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(URL.self, forKey: .url)
        let throwableRoas = try? container.decodeIfPresent(
            [Throwable<Roa>].self,
            forKey: .roas)
        self.roas = throwableRoas?.compactMap { try? $0.result.get() } ?? []
        self.tolerance = try? container.decodeIfPresent(
            Tolerance.self,
            forKey: .tolerance
        )
        self.addictionPotential = try? container.decodeIfPresent(
            String.self,
            forKey: .addictionPotential
        )
        self.toxicities = (try? container.decodeIfPresent(
            [String].self,
            forKey: .toxicity
        )) ?? []
        let crossNames = (try? container.decodeIfPresent(
            [String].self,
            forKey: .crossTolerances
        )) ?? []
        self.crossTolerances = crossNames.map {$0.removeGreekLetters.capitalizedIfNotAlready}
        let decodedUncertain = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .uncertainInteractions
        )) ?? []
        self.uncertainInteractions = decodedUncertain.map { dec in
            dec.name.removeGreekLetters.capitalizedIfNotAlready
        }
        let decodedUnsafe = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .unsafeInteractions
        )) ?? []
        self.unsafeInteractions = decodedUnsafe.map { dec in
            dec.name.removeGreekLetters.capitalizedIfNotAlready
        }
        let decodedDangerous = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .dangerousInteractions
        )) ?? []
        self.dangerousInteractions = decodedDangerous.map { dec in
            dec.name.removeGreekLetters.capitalizedIfNotAlready
        }
        let decodedClasses = try? container.decodeIfPresent(DecodedClasses.self, forKey: .category)
        self.psychoactiveClasses = decodedClasses?.psychoactive.map { name in
            name.validClassName
        } ?? []
        self.chemicalClasses = decodedClasses?.chemical.map { name in
            name.validClassName
        } ?? []
    }

    var administrationRoutesUnwrapped: [AdministrationRoute] {
        roas.map { roa in
            roa.name
        }
    }

    func getDuration(for administrationRoute: AdministrationRoute) -> RoaDuration? {
        let filteredRoas = roas.filter { roa in
            roa.name == administrationRoute
        }

        guard let duration = filteredRoas.first?.duration else {
            return nil
        }
        return duration
    }

    func getDose(for administrationRoute: AdministrationRoute?) -> RoaDose? {
        guard let administrationRoute = administrationRoute else {
            return nil
        }
        let filteredRoas = roas.filter { roa in
            roa.name == administrationRoute
        }
        guard let dose = filteredRoas.first?.dose else {
            return nil
        }
        return dose
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
        "MAOI",
        "Opioids",
        "Benzodiazepines",
        "Classic Psychedelics",
        "Psychedelics",
        "Serotonergic Psychedelic",
        "25x-NBOH",
        "Antidepressants",
        "Barbiturates",
        "Substituted Aminorexes",
        "Substituted Amphetamines",
        "Substituted Cathinones",
        "Substituted Morphinans",
        "Substituted Phenethylamines",
        "Substituted Phenidates",
        "Substituted Tryptamines",
        "Classical Psychedelics",
        "Diarylethylamines",
        "Dissociatives",
        "Entactogens",
        "Gabapentinoids",
        "Hallucinogens",
        "Lysergamides",
        "Thienodiazepines",
        "Xanthines",
        "Arylcyclohexylamines",
        "Entheogen",
        "Racetams",
        "Sedative",
        "Stimulants",
        "Eugeroics"
    ].map({$0.lowercased()}))
}

private struct DecodedInteraction: Decodable {
    var name: String
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
            self.psychoactive = []
        }
        let chems = try? container.decodeIfPresent([String].self, forKey: .chemical)
        if let chemsUnwrap = chems, !chemsUnwrap.isEmpty {
            self.chemical = chemsUnwrap
        } else {
            self.chemical = []
        }
    }
}
