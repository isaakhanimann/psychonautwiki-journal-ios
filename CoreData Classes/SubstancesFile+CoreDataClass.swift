import Foundation
import CoreData

public class SubstancesFile: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case substances
    }

    enum DecodingError: Error {
        case notEnoughSubstancesParsed
    }

    var substances: [Substance] = []

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
        self.substances = substances
        goThroughSubstancesOneByOneAndCreateObjectsAndRelationships(context: context)
    }

    private func goThroughSubstancesOneByOneAndCreateObjectsAndRelationships(context: NSManagedObjectContext) {
        createClasses(context: context)
        createEffectsAndAddThemToSubstances(context: context)
        // The following 2 methods must be called after the classes have been constructed
        createCrossTolerances()
        createInteractions(context: context)
    }

    private func createClasses(context: NSManagedObjectContext) {
        var psychoactives = Set<PsychoactiveClass>()
        var chemicals = Set<ChemicalClass>()
        for substance in substances {
            for psychoactiveName in substance.decodedClasses?.psychoactive ?? [] {
                let match = psychoactives.first { cat in
                    cat.nameUnwrapped.lowercased() == psychoactiveName.lowercased()
                }
                if let matchUnwrapped = match {
                    matchUnwrapped.addToSubstances(substance)
                } else {
                    let pClass = PsychoactiveClass(context: context)
                    pClass.name = psychoactiveName
                    pClass.addToSubstances(substance)
                    psychoactives.insert(pClass)
                }
            }
            for chemicalName in substance.decodedClasses?.chemical ?? [] {
                let match = chemicals.first { cat in
                    cat.nameUnwrapped.lowercased() == chemicalName.lowercased()
                }
                if let matchUnwrapped = match {
                    matchUnwrapped.addToSubstances(substance)
                } else {
                    let cClass = ChemicalClass(context: context)
                    cClass.name = chemicalName
                    cClass.addToSubstances(substance)
                    chemicals.insert(cClass)
                }
            }
        }
        self.psychoactiveClasses = psychoactives as NSSet
        self.chemicalClasses = chemicals as NSSet
    }

    private func createEffectsAndAddThemToSubstances(context: NSManagedObjectContext) {
        var effects = Set<Effect>()
        for substance in substances {
            for decodedEff in substance.decodedEffects {
                let match = effects.first { eff in
                    eff.nameUnwrapped.hasEqualMeaning(other: decodedEff.name)
                }
                if let matchUnwrapped = match {
                    substance.addToEffects(matchUnwrapped)
                } else {
                    let newEffect = Effect(context: context)
                    newEffect.name = decodedEff.name.capitalized
                    newEffect.url = decodedEff.url
                    effects.insert(newEffect)
                    substance.addToEffects(newEffect)
                }
            }
        }
    }

    private func createCrossTolerances() {
        for substance in substances {
            for toleranceName in substance.decodedCrossTolerances {
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
                let matchSubstance = substances.first { sub in
                    sub.nameUnwrapped.hasEqualMeaning(other: toleranceName)
                }
                if let matchUnwrapped = matchSubstance {
                    substance.addToCrossToleranceSubstances(matchUnwrapped)
                    continue
                }
            }
        }
    }

    private func createInteractions(context: NSManagedObjectContext) {
        var unresolvedInteractions = Set<UnresolvedInteraction>()
        for substance in substances {
            let uncertainNames = substance.decodedUncertain.map { $0.name }
            unresolvedInteractions = addToPsychoactivesChemicalsSubstancesOrUnresolved(
                substance: substance,
                interactionNames: uncertainNames,
                interactionType: .uncertain,
                unresolvedsFromBefore: unresolvedInteractions,
                context: context
            )
            let unsafeNames = substance.decodedUnsafe.map { $0.name }
            unresolvedInteractions = addToPsychoactivesChemicalsSubstancesOrUnresolved(
                substance: substance,
                interactionNames: unsafeNames,
                interactionType: .unsafe,
                unresolvedsFromBefore: unresolvedInteractions,
                context: context
            )
            let dangerousNames = substance.decodedDangerous.map { $0.name }
            unresolvedInteractions = addToPsychoactivesChemicalsSubstancesOrUnresolved(
                substance: substance,
                interactionNames: dangerousNames,
                interactionType: .dangerous,
                unresolvedsFromBefore: unresolvedInteractions,
                context: context
            )
        }
    }

    private enum InteractionType {
        case uncertain, unsafe, dangerous
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private func addToPsychoactivesChemicalsSubstancesOrUnresolved(
        substance: Substance,
        interactionNames: [String],
        interactionType: InteractionType,
        unresolvedsFromBefore: Set<UnresolvedInteraction>,
        context: NSManagedObjectContext
    ) -> Set<UnresolvedInteraction> {
        var newUnresolveds = unresolvedsFromBefore
        for interactionName in interactionNames {
            // check if psychoactive
            let matchPsycho = self.psychoactiveClassesUnwrapped.first { psy in
                psy.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let psyUnwrap = matchPsycho {
                switch interactionType {
                case .uncertain:
                    substance.addToUncertainPsychoactives(psyUnwrap)
                case .unsafe:
                    substance.addToUnsafePsychoactives(psyUnwrap)
                case .dangerous:
                    substance.addToDangerousPsychoactives(psyUnwrap)
                }
                continue
            }
            // check if chemical
            let matchChemical = self.chemicalClassesUnwrapped.first { chem in
                chem.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let chemUnwrap = matchChemical {
                switch interactionType {
                case .uncertain:
                    substance.addToUncertainChemicals(chemUnwrap)
                case .unsafe:
                    substance.addToUnsafeChemicals(chemUnwrap)
                case .dangerous:
                    substance.addToDangerousChemicals(chemUnwrap)
                }
                continue
            }
            // check if substance
            let matchSub = self.substances.first { sub in
                sub.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let subUnwrap = matchSub {
                switch interactionType {
                case .uncertain:
                    substance.addToUncertainSubstances(subUnwrap)
                case .unsafe:
                    substance.addToUnsafeSubstances(subUnwrap)
                case .dangerous:
                    substance.addToDangerousSubstances(subUnwrap)
                }
                continue
            }
            // if still here there was no match
            // check if there are already unresolved interactions
            let unrMatch = unresolvedsFromBefore.first { unr in
                unr.nameUnwrapped.hasEqualMeaning(other: interactionName)
            }
            if let unrUnwrap = unrMatch {
                unrUnwrap.addToUncertainSubstances(substance)
            } else {
                let newUnresolved = UnresolvedInteraction(context: context)
                newUnresolved.name = interactionName.capitalized
                switch interactionType {
                case .uncertain:
                    substance.addToUncertainUnresolveds(newUnresolved)
                case .unsafe:
                    substance.addToUnsafeUnresolveds(newUnresolved)
                case .dangerous:
                    substance.addToDangerousUnresolveds(newUnresolved)
                }
                newUnresolveds.insert(newUnresolved)
            }
        }
        return newUnresolveds
    }

    static let namesOfUncontrolledSubstances = [
        "Caffeine",
        "Myristicin",
        "Choline bitartrate",
        "Citicoline"
    ]
}
