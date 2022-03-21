import Foundation
import CoreData

public class SubstancesFile: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case substances
    }

    enum DecodingError: Error {
        case notEnoughSubstancesParsed
    }

    private var substancesForParsing: [Substance] = []
    private var contextForParsing: NSManagedObjectContext!
    private var unresolvedsForParsing = Set<UnresolvedInteraction>()

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let throwableSubstances = try container.decode(
            [Throwable<Substance>].self,
            forKey: .substances)
        let substances = throwableSubstances.compactMap { try? $0.result.get() }
        if substances.count < 50 {
            throw DecodingError.notEnoughSubstancesParsed
        }
        self.init(context: context)
        self.substancesForParsing = substances
        self.contextForParsing = context
        goThroughSubstancesOneByOneAndCreateObjectsAndRelationships()
    }

    private func goThroughSubstancesOneByOneAndCreateObjectsAndRelationships() {
        createClasses()
        createEffectsAndAddThemToSubstances()
        // The following 2 methods must be called after the classes have been constructed
        createCrossTolerances()
        createInteractions()
    }

    private static let psychoactiveURLs = [
        "Antipsychotics": URL(string: "https://psychonautwiki.org/wiki/Antipsychotic"),
        "Cannabinoids": URL(string: "https://psychonautwiki.org/wiki/Cannabinoid"),
        "Deliriants": URL(string: "https://psychonautwiki.org/wiki/Deliriant"),
        "Depressants": URL(string: "https://psychonautwiki.org/wiki/Depressant"),
        "Dissociatives": URL(string: "https://psychonautwiki.org/wiki/Dissociatives"),
        "Entactogens": URL(string: "https://psychonautwiki.org/wiki/Entactogens"),
        "Entheogens": URL(string: "https://psychonautwiki.org/wiki/Entheogen"),
        "Eugeroics": URL(string: "https://psychonautwiki.org/wiki/Eugeroics"),
        "Hallucinogens": URL(string: "https://psychonautwiki.org/wiki/Hallucinogens"),
        "Nootropics": URL(string: "https://psychonautwiki.org/wiki/Nootropic"),
        "Oneirogens": URL(string: "https://psychonautwiki.org/wiki/Oneirogen"),
        "Opioids": URL(string: "https://psychonautwiki.org/wiki/Opioids"),
        "Psychedelics": URL(string: "https://psychonautwiki.org/wiki/Psychedelics"),
        "Stimulants": URL(string: "https://psychonautwiki.org/wiki/Stimulants")
    ]

    private static let chemicalURLs = [
        "Adamantanes": URL(string: "https://psychonautwiki.org/wiki/Adamantanes"),
        "Alcohols": URL(string: "https://psychonautwiki.org/wiki/Alcohol"),
        "Amphetamines": URL(string: "https://psychonautwiki.org/wiki/Substituted_amphetamine"),
        "Arylcyclohexylamines": URL(string: "https://psychonautwiki.org/wiki/Arylcyclohexylamine"),
        "Barbiturates": URL(string: "https://psychonautwiki.org/wiki/Barbiturates"),
        "Benzodiazepines": URL(string: "https://psychonautwiki.org/wiki/Benzodiazepines"),
        "Cannabinoids": URL(string: "https://psychonautwiki.org/wiki/Cannabinoid"),
        "Cycloalkylamines": URL(string: "https://psychonautwiki.org/wiki/Cycloalkylamine"),
        "Diarylethylamines": URL(string: "https://psychonautwiki.org/wiki/Diarylethylamine"),
        "Gabapentinoids": URL(string: "https://psychonautwiki.org/wiki/Gabapentinoids"),
        "Indazoles": URL(string: "https://psychonautwiki.org/wiki/Indazole"),
        "Khat#1#s": URL(string: "https://psychonautwiki.org/wiki/Substituted_cathinone"),
        "Lysergamides": URL(string: "https://psychonautwiki.org/wiki/Lysergamides"),
        "Phenylpropenes": URL(string: "https://psychonautwiki.org/wiki/Phenylpropene"),
        "Racetams": URL(string: "https://psychonautwiki.org/wiki/Racetam"),
        "Salvinorins": URL(string: "https://psychonautwiki.org/wiki/Salvinorin"),
        "Substituted Amphetamines": URL(string: "https://psychonautwiki.org/wiki/Substituted_amphetamine"),
        "Substituted Cathinones": URL(string: "https://psychonautwiki.org/wiki/Cathinones"),
        "Substituted Morphinans": URL(string: "https://psychonautwiki.org/wiki/Morphinan"),
        "Substituted Phenethylamines": URL(string: "https://psychonautwiki.org/wiki/Phenethylamines"),
        "Substituted Phenidates": URL(string: "https://psychonautwiki.org/wiki/Phenidates"),
        "Substituted Piperazines": URL(string: "https://psychonautwiki.org/wiki/Piperazines"),
        "Substituted Piperidines": URL(string: "https://psychonautwiki.org/wiki/Piperidine"),
        "Substituted Tropanes": URL(string: "https://psychonautwiki.org/wiki/Tropanes"),
        "Substituted Tryptamines": URL(string: "https://psychonautwiki.org/wiki/Tryptamines"),
        "Thienodiazepines": URL(string: "https://psychonautwiki.org/wiki/Thienodiazepine"),
        "Xanthines": URL(string: "https://psychonautwiki.org/wiki/Xanthine")
    ]

    private func createClasses() {
        var psychoactives = Set<PsychoactiveClass>()
        var chemicals = Set<ChemicalClass>()
        for substance in substancesForParsing {
            for psychoactiveName in substance.decodedPsychoactiveNames {
                let match = psychoactives.first { cat in
                    cat.nameUnwrapped.hasEqualMeaning(other: psychoactiveName)
                }
                if let matchUnwrapped = match {
                    matchUnwrapped.addToSubstances(substance)
                } else {
                    let newPsy = PsychoactiveClass(context: contextForParsing)
                    if let url = Self.psychoactiveURLs[psychoactiveName] {
                        newPsy.url = url
                    }
                    newPsy.name = psychoactiveName
                    newPsy.addToSubstances(substance)
                    psychoactives.insert(newPsy)
                }
            }
            for chemicalName in substance.decodedChemicalNames {
                let match = chemicals.first { cat in
                    cat.nameUnwrapped.hasEqualMeaning(other: chemicalName)
                }
                if let matchUnwrapped = match {
                    matchUnwrapped.addToSubstances(substance)
                } else {
                    let cClass = ChemicalClass(context: contextForParsing)
                    if let url = Self.chemicalURLs[chemicalName] {
                        cClass.url = url
                    }
                    cClass.name = chemicalName
                    cClass.addToSubstances(substance)
                    chemicals.insert(cClass)
                }
            }
        }
        self.psychoactiveClasses = psychoactives as NSSet
        self.chemicalClasses = chemicals as NSSet
    }

    private func createEffectsAndAddThemToSubstances() {
        var effects = Set<Effect>()
        for substance in substancesForParsing {
            for decodedEff in substance.decodedEffects {
                let match = effects.first { eff in
                    eff.nameUnwrapped.hasEqualMeaning(other: decodedEff.name)
                }
                if let matchUnwrapped = match {
                    substance.addToEffects(matchUnwrapped)
                } else {
                    let newEffect = Effect(context: contextForParsing)
                    newEffect.name = decodedEff.name
                    newEffect.url = decodedEff.url
                    effects.insert(newEffect)
                    substance.addToEffects(newEffect)
                }
            }
        }
    }

    private func createCrossTolerances() {
        for substance in substancesForParsing {
            for toleranceName in substance.decodedCrossToleranceNames {
                if let matchUnwrapped = getFirstPsyMatch(with: toleranceName) {
                    substance.addToCrossTolerancePsychoactives(matchUnwrapped)
                    continue
                }
                if let matchUnwrapped = getFirstChemMatch(with: toleranceName) {
                    substance.addToCrossToleranceChemicals(matchUnwrapped)
                    continue
                }
                if let matchUnwrapped = getFirsSubMatch(with: toleranceName) {
                    substance.addToCrossToleranceSubstances(matchUnwrapped)
                    continue
                }
            }
        }
    }

    private func getFirstPsyMatch(with name: String) -> PsychoactiveClass? {
        return self.psychoactiveClassesUnwrapped.first { psy in
            psy.nameUnwrapped.hasEqualMeaning(other: name)
        }
    }

    private func getFirstChemMatch(with name: String) -> ChemicalClass? {
        return self.chemicalClassesUnwrapped.first { chem in
            chem.nameUnwrapped.hasEqualMeaning(other: name)
        }
    }

    private func getFirsSubMatch(with name: String) -> Substance? {
        return self.substancesForParsing.first { sub in
            sub.nameUnwrapped.hasEqualMeaning(other: name)
        }
    }

    private func getFirsUnrMatch(with name: String) -> UnresolvedInteraction? {
        return self.unresolvedsForParsing.first { unr in
            unr.nameUnwrapped.hasEqualMeaning(other: name)
        }
    }

    private func createInteractions() {
        unresolvedsForParsing = Set<UnresolvedInteraction>()
        for substance in substancesForParsing {
            goThroughInteractionsToAdd(
                substanceAddable: AddToUncertainSubstance(substance: substance),
                interactionNames: substance.decodedUncertainNames
            )
            goThroughInteractionsToAdd(
                substanceAddable: AddToUnsafeSubstance(substance: substance),
                interactionNames: substance.decodedUnsafeNames
            )
            goThroughInteractionsToAdd(
                substanceAddable: AddToDangerousSubstance(substance: substance),
                interactionNames: substance.decodedDangerousNames
            )
        }
    }

    private func goThroughInteractionsToAdd(
        substanceAddable: SubstanceAddable,
        interactionNames: [String]
    ) {
        for interactionName in interactionNames {
            addToPsychoactivesChemicalsSubstancesOrUnresolved(
                substanceAddable: substanceAddable,
                interactionName: interactionName
            )
        }
    }

    private func addToPsychoactivesChemicalsSubstancesOrUnresolved(
        substanceAddable: SubstanceAddable,
        interactionName: String
    ) {
        if let psyUnwrap = getFirstPsyMatch(with: interactionName) {
            substanceAddable.addToPsychoactives(psychocative: psyUnwrap)
            return
        }
        if let chemUnwrap = getFirstChemMatch(with: interactionName) {
            substanceAddable.addToChemicals(chemical: chemUnwrap)
            return
        }
        let substanceMatches = getSubstanceMatchesWithWildcards(wildcardName: interactionName)
        for matchingSubstance in substanceMatches {
            substanceAddable.addToSubstances(sub: matchingSubstance)
        }
        if !substanceMatches.isEmpty {
            return
        }
        // if still here there was no match
        if let unrUnwrap = getFirsUnrMatch(with: interactionName) {
            substanceAddable.addToUnresolved(unresolved: unrUnwrap)
        } else {
            let newUnresolved = UnresolvedInteraction(context: contextForParsing)
            newUnresolved.name = interactionName
            substanceAddable.addToUnresolved(unresolved: newUnresolved)
            unresolvedsForParsing.insert(newUnresolved)
        }
    }

    private func getSubstanceMatchesWithWildcards(wildcardName: String) -> [Substance] {
        if let regex = try? wildcardName.getRegexWithxAsWildcard() {
            let matchingSubstances = substancesForParsing.filter { sub in
                regex.isMatch(with: sub.nameUnwrapped)
            }
            return matchingSubstances
        }
        return []
    }
}

private protocol SubstanceAddable {
    func addToChemicals(chemical: ChemicalClass)
    func addToPsychoactives(psychocative: PsychoactiveClass)
    func addToSubstances(sub: Substance)
    func addToUnresolved(unresolved: UnresolvedInteraction)
}

private struct AddToUncertainSubstance: SubstanceAddable {

    let substance: Substance

    func addToChemicals(chemical: ChemicalClass) {
        substance.addToUncertainChemicals(chemical)
    }

    func addToPsychoactives(psychocative: PsychoactiveClass) {
        substance.addToUncertainPsychoactives(psychocative)
    }

    func addToSubstances(sub: Substance) {
        substance.addToUncertainSubstances(sub)
    }

    func addToUnresolved(unresolved: UnresolvedInteraction) {
        substance.addToUncertainUnresolveds(unresolved)
    }
}

private struct AddToUnsafeSubstance: SubstanceAddable {

    let substance: Substance

    func addToChemicals(chemical: ChemicalClass) {
        substance.addToUnsafeChemicals(chemical)
    }

    func addToPsychoactives(psychocative: PsychoactiveClass) {
        substance.addToUnsafePsychoactives(psychocative)
    }

    func addToSubstances(sub: Substance) {
        substance.addToUnsafeSubstances(sub)
    }

    func addToUnresolved(unresolved: UnresolvedInteraction) {
        substance.addToUnsafeUnresolveds(unresolved)
    }
}

private struct AddToDangerousSubstance: SubstanceAddable {

    let substance: Substance

    func addToChemicals(chemical: ChemicalClass) {
        substance.addToDangerousChemicals(chemical)
    }

    func addToPsychoactives(psychocative: PsychoactiveClass) {
        substance.addToDangerousPsychoactives(psychocative)
    }

    func addToSubstances(sub: Substance) {
        substance.addToDangerousSubstances(sub)
    }

    func addToUnresolved(unresolved: UnresolvedInteraction) {
        substance.addToDangerousUnresolveds(unresolved)
    }
}
