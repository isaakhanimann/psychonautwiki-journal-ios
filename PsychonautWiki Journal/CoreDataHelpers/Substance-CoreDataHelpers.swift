import Foundation
import CoreData

extension Substance: Comparable {

    public static func < (lhs: Substance, rhs: Substance) -> Bool {
        lhs.nameUnwrapped < rhs.nameUnwrapped
    }

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var psychoactivesUnwrapped: [PsychoactiveClass] {
        (psychoactiveClasses?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    var firstPsychoactiveNameUnwrapped: String {
        firstPsychoactiveName ?? Self.noClassName
    }

    var firstChemicalNameUnwrapped: String {
        firstChemicalName ?? Self.noClassName
    }

    var chemicalsUnwrapped: [ChemicalClass] {
        (chemicalClasses?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    var addictionPotentialUnwrapped: String? {
        addictionPotential?.optionalIfEmpty
    }

    var toxicityUnwrapped: String? {
        toxicity?.optionalIfEmpty
    }

    var roasUnwrapped: [Roa] {
        roas?.allObjects as? [Roa] ?? []
    }

    var crossToleranceSubstancesUnwrapped: [Substance] {
        (crossToleranceSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var crossTolerancePsychoactivesUnwrapped: [PsychoactiveClass] {
        (crossTolerancePsychoactives?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    var crossToleranceChemicalsUnwrapped: [ChemicalClass] {
        (crossToleranceChemicals?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    private var uncertainSubstancesUnwrapped: [Substance] {
        (uncertainSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    private var uncertainPsychoactivesUnwrapped: [PsychoactiveClass] {
        (uncertainPsychoactives?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    private var uncertainChemicalsUnwrapped: [ChemicalClass] {
        (uncertainChemicals?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    private var uncertainUnresolvedsUnwrapped: [UnresolvedInteraction] {
        (uncertainUnresolveds?.allObjects as? [UnresolvedInteraction] ?? []).sorted()
    }

    private var unsafeSubstancesUnwrapped: [Substance] {
        (unsafeSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    private var unsafePsychoactivesUnwrapped: [PsychoactiveClass] {
        (unsafePsychoactives?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    private var unsafeChemicalsUnwrapped: [ChemicalClass] {
        (unsafeChemicals?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    private var unsafeUnresolvedsUnwrapped: [UnresolvedInteraction] {
        (unsafeUnresolveds?.allObjects as? [UnresolvedInteraction] ?? []).sorted()
    }

    private var dangerousSubstancesUnwrapped: [Substance] {
        (dangerousSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    private var dangerousPsychoactivesUnwrapped: [PsychoactiveClass] {
        (dangerousPsychoactives?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    private var dangerousChemicalsUnwrapped: [ChemicalClass] {
        (dangerousChemicals?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    private var dangerousUnresolvedsUnwrapped: [UnresolvedInteraction] {
        (dangerousUnresolveds?.allObjects as? [UnresolvedInteraction] ?? []).sorted()
    }

    var effectsUnwrapped: [Effect] {
        (effects?.allObjects as? [Effect] ?? []).sorted()
    }

    var administrationRoutesUnwrapped: [AdministrationRoute] {
        roasUnwrapped.map { roa in
            roa.nameUnwrapped
        }
    }

    func getDuration(for administrationRoute: AdministrationRoute) -> RoaDuration? {
        let filteredRoas = roasUnwrapped.filter { roa in
            roa.nameUnwrapped == administrationRoute
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
        let filteredRoas = roasUnwrapped.filter { roa in
            roa.nameUnwrapped == administrationRoute
        }
        guard let dose = filteredRoas.first?.dose else {
            return nil
        }
        return dose
    }

    var hasAnyInteractions: Bool {
        guard uncertainSubstancesUnwrapped.isEmpty else {return true}
        guard uncertainPsychoactivesUnwrapped.isEmpty else {return true}
        guard uncertainChemicalsUnwrapped.isEmpty else {return true}
        guard uncertainUnresolvedsUnwrapped.isEmpty else {return true}
        guard unsafeSubstancesUnwrapped.isEmpty else {return true}
        guard unsafePsychoactivesUnwrapped.isEmpty else {return true}
        guard unsafeChemicalsUnwrapped.isEmpty else {return true}
        guard unsafeUnresolvedsUnwrapped.isEmpty else {return true}
        guard dangerousSubstancesUnwrapped.isEmpty else {return true}
        guard dangerousPsychoactivesUnwrapped.isEmpty else {return true}
        guard dangerousChemicalsUnwrapped.isEmpty else {return true}
        guard dangerousUnresolvedsUnwrapped.isEmpty else {return true}
        return false
    }

    func getInteraction(with otherSubstance: Substance) -> InteractionType {
        if dangerousSubstancesUnwrapped.contains(otherSubstance) ||
            dangerousPsychoactivesContain(substance: otherSubstance) ||
            dangerousChemicalsContain(substance: otherSubstance) {
            return .dangerous
        }
        if unsafeSubstancesUnwrapped.contains(otherSubstance) ||
            unsafePsychoactivesContain(substance: otherSubstance) ||
            unsafeChemicalsContain(substance: otherSubstance) {
            return .unsafe
        }
        if uncertainSubstancesUnwrapped.contains(otherSubstance) ||
            uncertainPsychoactivesContain(substance: otherSubstance) ||
            uncertainChemicalsContain(substance: otherSubstance) {
            return .uncertain
        }
        return .none
    }
}

extension Substance: SubstanceInteractable {
    var areThereInteractions: Bool {
        guard uncertainSubstancesUnwrapped.isEmpty else {return true}
        guard uncertainPsychoactivesUnwrapped.isEmpty else {return true}
        guard uncertainChemicalsUnwrapped.isEmpty else {return true}
        guard uncertainUnresolvedsUnwrapped.isEmpty else {return true}
        guard unsafeSubstancesUnwrapped.isEmpty else {return true}
        guard unsafePsychoactivesUnwrapped.isEmpty else {return true}
        guard unsafeChemicalsUnwrapped.isEmpty else {return true}
        guard unsafeUnresolvedsUnwrapped.isEmpty else {return true}
        guard dangerousSubstancesUnwrapped.isEmpty else {return true}
        guard dangerousPsychoactivesUnwrapped.isEmpty else {return true}
        guard dangerousChemicalsUnwrapped.isEmpty else {return true}
        guard dangerousUnresolvedsUnwrapped.isEmpty else {return true}
        return false
    }

    var showTolerance: Bool {
        tolerance?.isAtLeastOneDefined ?? false
    }

    var showPsychoactiveClass: Bool {
        !psychoactivesUnwrapped.isEmpty
    }

    var showChemicalClass: Bool {
        !chemicalsUnwrapped.isEmpty
    }

    var showEffects: Bool {
        !effectsUnwrapped.isEmpty
    }

    var showCrossTolerance: Bool {
        let hasSubs = !crossToleranceSubstancesUnwrapped.isEmpty
        let hasPsych = !crossTolerancePsychoactivesUnwrapped.isEmpty
        let hasChem = !crossToleranceChemicalsUnwrapped.isEmpty
        return hasSubs || hasPsych || hasChem
    }

    var dangerousPsychoactivesToShow: [PsychoactiveClass] {
        dangerousPsychoactivesUnwrapped
    }

    var unsafePsychoactivesToShow: [PsychoactiveClass] {
        unsafePsychoactivesUnwrapped.filter { psy in
            !dangerousPsychoactivesToShow.contains(psy)
        }
    }

    var uncertainPsychoactivesToShow: [PsychoactiveClass] {
        uncertainPsychoactivesUnwrapped.filter { psy in
            !dangerousPsychoactivesUnwrapped.contains(psy) && !unsafePsychoactivesUnwrapped.contains(psy)
        }
    }

    var dangerousChemicalsToShow: [ChemicalClass] {
        dangerousChemicalsUnwrapped
    }

    var unsafeChemicalsToShow: [ChemicalClass] {
        unsafeChemicalsUnwrapped.filter { che in
            !dangerousChemicalsToShow.contains(che)
        }
    }

    var uncertainChemicalsToShow: [ChemicalClass] {
        uncertainChemicalsUnwrapped.filter { che in
            !dangerousChemicalsUnwrapped.contains(che) && !unsafeChemicalsUnwrapped.contains(che)
        }
    }

    var dangerousUnresolvedsToShow: [UnresolvedInteraction] {
        dangerousUnresolvedsUnwrapped
    }

    var unsafeUnresolvedsToShow: [UnresolvedInteraction] {
        unsafeUnresolvedsUnwrapped.filter { unr in
            !dangerousUnresolvedsToShow.contains(unr)
        }
    }

    var uncertainUnresolvedsToShow: [UnresolvedInteraction] {
        uncertainUnresolvedsUnwrapped.filter { unr in
            !dangerousUnresolvedsUnwrapped.contains(unr) && !unsafeUnresolvedsUnwrapped.contains(unr)
        }
    }

    var dangerousSubstancesToShow: [Substance] {
        dangerousSubstancesUnwrapped.filter { sub in
            !dangerousPsychoactivesContain(substance: sub) && !dangerousChemicalsContain(substance: sub)
        }
    }

    var unsafeSubstancesToShow: [Substance] {
        unsafeSubstancesUnwrapped.filter { sub in
            !dangerousPsychoactivesContain(substance: sub) && !dangerousChemicalsContain(substance: sub)
            && !unsafePsychoactivesContain(substance: sub) && !unsafeChemicalsContain(substance: sub)
        }
    }

    var uncertainSubstancesToShow: [Substance] {
        uncertainSubstancesUnwrapped.filter { sub in
            !dangerousPsychoactivesContain(substance: sub) && !dangerousChemicalsContain(substance: sub)
            && !unsafePsychoactivesContain(substance: sub) && !unsafeChemicalsContain(substance: sub)
            && !uncertainPsychoactivesContain(substance: sub) && !uncertainChemicalsContain(substance: sub)
        }
    }

    func uncertainChemicalsContain(substance: Substance) -> Bool {
        uncertainChemicalsUnwrapped.contains { che in
            che.containsSubstance(substance: substance)
        }
    }

    func uncertainPsychoactivesContain(substance: Substance) -> Bool {
        uncertainPsychoactivesUnwrapped.contains { psy in
            psy.containsSubstance(substance: substance)
        }
    }

    func unsafeChemicalsContain(substance: Substance) -> Bool {
        unsafeChemicalsUnwrapped.contains { che in
            che.containsSubstance(substance: substance)
        }
    }

    func unsafePsychoactivesContain(substance: Substance) -> Bool {
        unsafePsychoactivesUnwrapped.contains { psy in
            psy.containsSubstance(substance: substance)
        }
    }

    func dangerousChemicalsContain(substance: Substance) -> Bool {
        dangerousChemicalsUnwrapped.contains { che in
            che.containsSubstance(substance: substance)
        }
    }

    func dangerousPsychoactivesContain(substance: Substance) -> Bool {
        dangerousPsychoactivesUnwrapped.contains { psy in
            psy.containsSubstance(substance: substance)
        }
    }

    var hasDangerousInteractionsToShow: Bool {
        !dangerousSubstancesToShow.isEmpty ||
        !dangerousPsychoactivesToShow.isEmpty ||
        !dangerousChemicalsToShow.isEmpty ||
        !dangerousUnresolvedsToShow.isEmpty
    }

    var hasUnsafeInteractionsToShow: Bool {
        !unsafeSubstancesToShow.isEmpty ||
        !unsafePsychoactivesToShow.isEmpty ||
        !unsafeChemicalsToShow.isEmpty ||
        !unsafeUnresolvedsToShow.isEmpty
    }

    var hasUncertainInteractionsToShow: Bool {
        !uncertainSubstancesToShow.isEmpty ||
        !uncertainPsychoactivesToShow.isEmpty ||
        !uncertainChemicalsToShow.isEmpty ||
        !uncertainUnresolvedsToShow.isEmpty
    }

    func isDangerous(with otherSubstance: Substance) -> Bool {
        dangerousChemicalsContain(substance: otherSubstance) ||
        dangerousPsychoactivesContain(substance: otherSubstance) ||
        dangerousSubstancesUnwrapped.contains(otherSubstance)
    }

    func isUnsafe(with otherSubstance: Substance) -> Bool {
        unsafeChemicalsContain(substance: otherSubstance) ||
        unsafePsychoactivesContain(substance: otherSubstance) ||
        unsafeSubstancesUnwrapped.contains(otherSubstance)
    }

    func isUncertain(with otherSubstance: Substance) -> Bool {
        uncertainChemicalsContain(substance: otherSubstance) ||
        uncertainPsychoactivesContain(substance: otherSubstance) ||
        uncertainSubstancesUnwrapped.contains(otherSubstance)
    }
}
