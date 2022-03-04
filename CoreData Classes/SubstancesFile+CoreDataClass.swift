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
        "Hallucinogens": URL(string: "https://psychonautwiki.org/wiki/Hallucinogens"),
        "Nootropics": URL(string: "https://psychonautwiki.org/wiki/Nootropic"),
        "Opioids": URL(string: "https://psychonautwiki.org/wiki/Opioids"),
        "Psychedelics": URL(string: "https://psychonautwiki.org/wiki/Psychedelics"),
        "Stimulants": URL(string: "https://psychonautwiki.org/wiki/Stimulants")
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
                    newEffect.name = decodedEff.name.capitalized
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
                // check if psychoactive
                let matchPsycho = self.psychoactiveClassesUnwrapped.first { psy in
                    psy.nameUnwrapped.hasEqualMeaning(other: toleranceName)
                }
                if let matchUnwrapped = matchPsycho {
                    substance.addToCrossTolerancePsychoactives(matchUnwrapped)
                    continue
                }
                // check if chemical
                let matchChemical = self.chemicalClassesUnwrapped.first { chem in
                    chem.nameUnwrapped.hasEqualMeaning(other: toleranceName)
                }
                if let matchUnwrapped = matchChemical {
                    substance.addToCrossToleranceChemicals(matchUnwrapped)
                    continue
                }
                // check if substance
                let matchSubstance = substancesForParsing.first { sub in
                    sub.nameUnwrapped.hasEqualMeaning(other: toleranceName)
                }
                if let matchUnwrapped = matchSubstance {
                    substance.addToCrossToleranceSubstances(matchUnwrapped)
                    continue
                }
            }
        }
    }

    private func createInteractions() {
        unresolvedsForParsing = Set<UnresolvedInteraction>()
        for substance in substancesForParsing {
            addToPsychoactivesChemicalsSubstancesOrUnresolved(
                substanceAddable: AddToUncertainSubstance(substance: substance),
                interactionNames: substance.decodedUncertainNames
            )
            addToPsychoactivesChemicalsSubstancesOrUnresolved(
                substanceAddable: AddToUnsafeSubstance(substance: substance),
                interactionNames: substance.decodedUnsafeNames
            )
            addToPsychoactivesChemicalsSubstancesOrUnresolved(
                substanceAddable: AddToDangerousSubstance(substance: substance),
                interactionNames: substance.decodedDangerousNames
            )
        }
    }

    private enum InteractionType {
        case uncertain, unsafe, dangerous
    }

    private func addToPsychoactivesChemicalsSubstancesOrUnresolved(
        substanceAddable: SubstanceAddable,
        interactionNames: [String]
    ) {
        for interactionName in interactionNames {
            // check if psychoactive
            let matchPsycho = self.psychoactiveClassesUnwrapped.first { psy in
                psy.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let psyUnwrap = matchPsycho {
                substanceAddable.addToPsychoactives(psychocative: psyUnwrap)
                continue
            }
            // check if chemical
            let matchChemical = self.chemicalClassesUnwrapped.first { chem in
                chem.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let chemUnwrap = matchChemical {
                substanceAddable.addToChemicals(chemical: chemUnwrap)
                continue
            }
            // check if substance
            let matchSub = self.substancesForParsing.first { sub in
                sub.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let subUnwrap = matchSub {
                substanceAddable.addToSubstances(sub: subUnwrap)
                continue
            }
            // if still here there was no match
            // check if there are already unresolved interactions
            let unrMatch = unresolvedsForParsing.first { unr in
                unr.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let unrUnwrap = unrMatch {
                substanceAddable.addToUnresolved(unresolved: unrUnwrap)
            } else {
                let newUnresolved = UnresolvedInteraction(context: contextForParsing)
                newUnresolved.name = interactionName.capitalized
                substanceAddable.addToUnresolved(unresolved: newUnresolved)
                unresolvedsForParsing.insert(newUnresolved)
            }
        }
    }

    static let namesOfUncontrolledSubstances = [
        "Caffeine",
        "Myristicin",
        "Choline bitartrate",
        "Citicoline"
    ]
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
