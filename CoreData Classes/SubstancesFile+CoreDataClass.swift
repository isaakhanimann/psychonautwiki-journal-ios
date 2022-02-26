import Foundation
import CoreData

public class SubstancesFile: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case substances
    }

    enum DecodingError: Error {
        case notEnoughSubstancesParsed
    }

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
        goThroughSubstancesOneByOneAndCreateObjectsAndRelationships(substances: substances, context: context)
    }

    private func goThroughSubstancesOneByOneAndCreateObjectsAndRelationships(
        substances: [Substance],
        context: NSManagedObjectContext
    ) {
        createClasses(substances: substances, context: context)
        createEffectsAndAddThemToSubstances(substances: substances, context: context)
        // The following 2 methods must be called after the classes have been constructed
        createCrossTolerances(substances: substances, context: context)
        createInteractions(substances: substances, context: context)
    }

    private func createClasses(
        substances: [Substance],
        context: NSManagedObjectContext
    ) {
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

    private func createEffectsAndAddThemToSubstances(
        substances: [Substance],
        context: NSManagedObjectContext
    ) {
        var effects = Set<Effect>()
        for substance in substances {
            for decodedEff in substance.decodedEffects {
                let match = effects.first { eff in
                    eff.nameUnwrapped.lowercased() == decodedEff.name.lowercased()
                }
                if let matchUnwrapped = match {
                    substance.addToEffects(matchUnwrapped)
                } else {
                    let newEffect = Effect(context: context)
                    newEffect.name = decodedEff.name
                    newEffect.url = decodedEff.url
                    effects.insert(newEffect)
                    substance.addToEffects(newEffect)
                }
            }
        }
    }

    private func createCrossTolerances(
        substances: [Substance],
        context: NSManagedObjectContext
    ) {
        for substance in substances {
            for toleranceName in substance.decodedCrossTolerances {
                // check if psychoactive
                let matchPsycho = self.psychoactiveClassesUnwrapped.first { psy in
                    psy.nameUnwrapped.lowercased() == toleranceName.lowercased()
                }
                if let matchUnwrapped = matchPsycho {
                    substance.addToCrossTolerancePsychoactives(matchUnwrapped)
                    continue
                }
                // check if chemical
                let matchChemical = self.chemicalClassesUnwrapped.first { chem in
                    chem.nameUnwrapped.lowercased() == toleranceName.lowercased()
                }
                if let matchUnwrapped = matchChemical {
                    substance.addToCrossToleranceChemicals(matchUnwrapped)
                    continue
                }
                // check if substance
                let matchSubstance = substances.first { sub in
                    sub.nameUnwrapped.lowercased() == toleranceName.lowercased()
                }
                if let matchUnwrapped = matchSubstance {
                    substance.addToCrossToleranceSubstances(matchUnwrapped)
                    continue
                }
            }
        }
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private func createInteractions(
        substances: [Substance],
        context: NSManagedObjectContext
    ) {
        var unresolvedInteractions = Set<UnresolvedInteraction>()
        for substance in substances {
            for uncertainInteraction in substance.decodedUncertain {
                // check if psychoactive
                let matchPsycho = self.psychoactiveClassesUnwrapped.first { psy in
                    psy.nameUnwrapped.lowercased() == uncertainInteraction.name.lowercased()
                }
                if let matchUnwrapped = matchPsycho {
                    substance.addToUncertainPsychoactives(matchUnwrapped)
                    continue
                }
                // check if chemical
                let matchChemical = self.chemicalClassesUnwrapped.first { chem in
                    chem.nameUnwrapped.lowercased() == uncertainInteraction.name.lowercased()
                }
                if let matchUnwrapped = matchChemical {
                    substance.addToUncertainChemicals(matchUnwrapped)
                    continue
                }
                // check if substance with x wildcard
                let regexString = uncertainInteraction.name.lowercased().replacingOccurrences(of: "x", with: "*")
                if let regex = try? NSRegularExpression(pattern: regexString, options: [.caseInsensitive]) {
                    let matchingSubstances = substances.filter { substance in
                        let range = NSRange(location: 0, length: substance.nameUnwrapped.utf16.count)
                        return regex.firstMatch(in: substance.nameUnwrapped, options: [], range: range) != nil
                    }
                    if !matchingSubstances.isEmpty {
                        for matchingSubstance in matchingSubstances {
                            matchingSubstance.addToUncertainSubstances(substance)
                        }
                    }
                }
                // if still here there was no match
                // check if there are already general interactions
                let firstGeneralMatch = unresolvedInteractions.first { generalInteraction in
                    generalInteraction.nameUnwrapped.lowercased() == uncertainInteraction.name.lowercased()
                }
                if let foundGeneral = firstGeneralMatch {
                    foundGeneral.addToUncertainSubstances(substance)
                } else {
                    let newUnresolved = UnresolvedInteraction(context: context)
                    newUnresolved.name = uncertainInteraction.name
                    substance.addToUncertainUnresolved(newUnresolved)
                    unresolvedInteractions.insert(newUnresolved)
                }
            }
            for unsafeInteraction in substance.decodedUnsafe {
                // check if psychoactive
                let matchPsycho = self.psychoactiveClassesUnwrapped.first { psy in
                    psy.nameUnwrapped.lowercased() == unsafeInteraction.name.lowercased()
                }
                if let matchUnwrapped = matchPsycho {
                    substance.addToUnsafePsychoactives(matchUnwrapped)
                    continue
                }
                // check if chemical
                let matchChemical = self.chemicalClassesUnwrapped.first { chem in
                    chem.nameUnwrapped.lowercased() == unsafeInteraction.name.lowercased()
                }
                if let matchUnwrapped = matchChemical {
                    substance.addToUnsafeChemicals(matchUnwrapped)
                    continue
                }
                // check if substance with x wildcard
                let regexString = unsafeInteraction.name.lowercased().replacingOccurrences(of: "x", with: "*")
                if let regex = try? NSRegularExpression(pattern: regexString, options: [.caseInsensitive]) {
                    let matchingSubstances = substances.filter { substance in
                        let range = NSRange(location: 0, length: substance.nameUnwrapped.utf16.count)
                        return regex.firstMatch(in: substance.nameUnwrapped, options: [], range: range) != nil
                    }
                    if !matchingSubstances.isEmpty {
                        for matchingSubstance in matchingSubstances {
                            matchingSubstance.addToUnsafeSubstances(substance)
                        }
                    }
                }
                // if still here there was no match
                // check if there are already general interactions
                let firstGeneralMatch = unresolvedInteractions.first { generalInteraction in
                    generalInteraction.nameUnwrapped.lowercased() == unsafeInteraction.name.lowercased()
                }
                if let foundGeneral = firstGeneralMatch {
                    foundGeneral.addToUnsafeSubstances(substance)
                } else {
                    let newUnresolved = UnresolvedInteraction(context: context)
                    newUnresolved.name = unsafeInteraction.name
                    substance.addToUnsafeUnresolved(newUnresolved)
                    unresolvedInteractions.insert(newUnresolved)
                }
            }
            for dangerousInteraction in substance.decodedDangerous {
                // check if psychoactive
                let matchPsycho = self.psychoactiveClassesUnwrapped.first { psy in
                    psy.nameUnwrapped.lowercased() == dangerousInteraction.name.lowercased()
                }
                if let matchUnwrapped = matchPsycho {
                    substance.addToDangerousPsychoactives(matchUnwrapped)
                    continue
                }
                // check if chemical
                let matchChemical = self.chemicalClassesUnwrapped.first { chem in
                    chem.nameUnwrapped.lowercased() == dangerousInteraction.name.lowercased()
                }
                if let matchUnwrapped = matchChemical {
                    substance.addToDangerousChemicals(matchUnwrapped)
                    continue
                }
                // check if substance with x wildcard
                let regexString = dangerousInteraction.name.lowercased().replacingOccurrences(of: "x", with: "*")
                if let regex = try? NSRegularExpression(pattern: regexString, options: [.caseInsensitive]) {
                    let matchingSubstances = substances.filter { substance in
                        let range = NSRange(location: 0, length: substance.nameUnwrapped.utf16.count)
                        return regex.firstMatch(in: substance.nameUnwrapped, options: [], range: range) != nil
                    }
                    if !matchingSubstances.isEmpty {
                        for matchingSubstance in matchingSubstances {
                            matchingSubstance.addToDangerousSubstances(substance)
                        }
                    }
                }
                // if still here there was no match
                // check if there are already general interactions
                let firstGeneralMatch = unresolvedInteractions.first { generalInteraction in
                    generalInteraction.nameUnwrapped.lowercased() == dangerousInteraction.name.lowercased()
                }
                if let foundGeneral = firstGeneralMatch {
                    foundGeneral.addToDangerousSubstances(substance)
                } else {
                    let newUnresolved = UnresolvedInteraction(context: context)
                    newUnresolved.name = dangerousInteraction.name
                    substance.addToDangerousUnresolved(newUnresolved)
                    unresolvedInteractions.insert(newUnresolved)
                }
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
