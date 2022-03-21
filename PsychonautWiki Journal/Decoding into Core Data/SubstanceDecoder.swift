import Foundation

struct SubstanceDecoder {
    private let container: KeyedDecodingContainer<CodingKeys>

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

    enum SubstanceDecodingError: Error {
        case invalidName(String)
    }

    init(decoder: Decoder) throws {
        container = try decoder.container(keyedBy: CodingKeys.self)
    }

    func getName() throws -> String {
        let decodedName = try container.decode(String.self, forKey: .name)
        if Self.namesThatShouldNotBeParsed.contains(decodedName.lowercased()) {
            throw SubstanceDecodingError.invalidName("\(decodedName) is not a substance")
        }
        if decodedName.lowercased().contains("experience") {
            throw SubstanceDecodingError.invalidName("substance name contains the word experience")
        }
        return decodedName.removeGreekLetters.capitalizedIfNotAlready
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
        "Entheogen"
    ].map({$0.lowercased()}))

    func getURL() -> URL? {
        try? container.decodeIfPresent(URL.self, forKey: .url)
    }

    func getEffects() -> [DecodedEffect] {
        (try? container.decodeIfPresent(
            [DecodedEffect].self,
            forKey: .effects
        )) ?? []
    }

    func getRoas() -> NSSet {
        let throwableRoas = try? container.decodeIfPresent(
            [Throwable<Roa>].self,
            forKey: .roas)
        let decodedRoas = throwableRoas?.compactMap { try? $0.result.get() }
        return Set(decodedRoas ?? []) as NSSet
    }

    func getTolerance() -> Tolerance? {
        try? container.decodeIfPresent(
            Tolerance.self,
            forKey: .tolerance
        )
    }

    func getAddictionPotential() -> String? {
        try? container.decodeIfPresent(
            String.self,
            forKey: .addictionPotential
        )
    }

    func getToxicity() -> String? {
        let toxicities = try? container.decodeIfPresent(
            [String].self,
            forKey: .toxicity
        )
        return toxicities?.first
    }

    func getToleranceNames() -> [String] {
        let toleranceNames = (try? container.decodeIfPresent(
            [String].self,
            forKey: .crossTolerances
        )) ?? []
        return toleranceNames.map {$0.removeGreekLetters.capitalizedIfNotAlready}
    }

    func getDangerousInteractions() -> [String] {
        let decodedDangerous = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .dangerousInteractions
        )) ?? []
        return decodedDangerous.map { dec in
            dec.name.removeGreekLetters.capitalizedIfNotAlready
        }
    }

    func getUnsafeInteractions() -> [String] {
        let decodedUnsafe = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .unsafeInteractions
        )) ?? []
        var unsafeNames = decodedUnsafe.map { dec in
            dec.name.removeGreekLetters.capitalizedIfNotAlready
        }
        let dangerNames = getDangerousInteractions()
        unsafeNames.removeAll { uns in
            dangerNames.contains { dang in
                uns == dang
            }
        }
        return unsafeNames
    }

    func getUncertainInteractions() -> [String] {
        let decodedUncertain = (try? container.decodeIfPresent(
            [DecodedInteraction].self,
            forKey: .uncertainInteractions
        )) ?? []
        var uncertainNames = decodedUncertain.map { dec in
            dec.name.removeGreekLetters.capitalizedIfNotAlready
        }
        let dangerNames = getDangerousInteractions()
        let unsafeNames = getUnsafeInteractions()
        let moreDangerousNames = dangerNames + unsafeNames
        uncertainNames.removeAll { unc in
            moreDangerousNames.contains { dang in
                unc == dang
            }
        }
        return uncertainNames
    }

    func getPsychoactiveNames() -> [String] {
        let decodedClasses = try? container.decodeIfPresent(DecodedClasses.self, forKey: .category)
        var psychoactiveNames = decodedClasses?.psychoactive.map { name in
            name.validClassName
        } ?? []
        if psychoactiveNames.isEmpty {
            psychoactiveNames.append(Substance.noClassName)
        }
        return psychoactiveNames
    }

    func getChemicalNames() -> [String] {
        let decodedClasses = try? container.decodeIfPresent(DecodedClasses.self, forKey: .category)
        var chemicalNames = decodedClasses?.chemical.map { name in
            name.validClassName
        } ?? []
        if chemicalNames.isEmpty {
            chemicalNames.append(Substance.noClassName)
        }
        return chemicalNames
    }
}

private struct DecodedInteraction: Decodable {
    var name: String
}

struct DecodedEffect: Decodable {
    var name: String
    var url: URL

    private enum CodingKeys: String, CodingKey {
        case name
        case url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        self.name = name.capitalized
        self.url = try container.decode(URL.self, forKey: .url)
    }
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
