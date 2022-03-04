import Foundation
import CoreData

extension Substance: Comparable, SubstanceInteractable {

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
        firstPsychoactiveName ?? noClassName
    }

    var firstChemicalNameUnwrapped: String {
        firstChemicalName ?? noClassName
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

    var uncertainSubstancesUnwrapped: [Substance] {
        (uncertainSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var uncertainPsychoactivesUnwrapped: [PsychoactiveClass] {
        (uncertainPsychoactives?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    var uncertainChemicalsUnwrapped: [ChemicalClass] {
        (uncertainChemicals?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    var uncertainUnresolvedsUnwrapped: [UnresolvedInteraction] {
        (uncertainUnresolveds?.allObjects as? [UnresolvedInteraction] ?? []).sorted()
    }

    var unsafeSubstancesUnwrapped: [Substance] {
        (unsafeSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var unsafePsychoactivesUnwrapped: [PsychoactiveClass] {
        (unsafePsychoactives?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    var unsafeChemicalsUnwrapped: [ChemicalClass] {
        (unsafeChemicals?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    var unsafeUnresolvedsUnwrapped: [UnresolvedInteraction] {
        (unsafeUnresolveds?.allObjects as? [UnresolvedInteraction] ?? []).sorted()
    }

    var dangerousSubstancesUnwrapped: [Substance] {
        (dangerousSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var dangerousPsychoactivesUnwrapped: [PsychoactiveClass] {
        (dangerousPsychoactives?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    var dangerousChemicalsUnwrapped: [ChemicalClass] {
        (dangerousChemicals?.allObjects as? [ChemicalClass] ?? []).sorted()
    }

    var dangerousUnresolvedsUnwrapped: [UnresolvedInteraction] {
        (dangerousUnresolveds?.allObjects as? [UnresolvedInteraction] ?? []).sorted()
    }

    var effectsUnwrapped: [Effect] {
        (effects?.allObjects as? [Effect] ?? []).sorted()
    }

    var administrationRoutesUnwrapped: [Roa.AdministrationRoute] {
        roasUnwrapped.map { roa in
            roa.nameUnwrapped
        }
    }

    func getDuration(for administrationRoute: Roa.AdministrationRoute) -> RoaDuration? {
        let filteredRoas = roasUnwrapped.filter { roa in
            roa.nameUnwrapped == administrationRoute
        }

        guard let duration = filteredRoas.first?.duration else {
            return nil
        }
        return duration
    }

    func getDose(for administrationRoute: Roa.AdministrationRoute) -> RoaDose? {
        let filteredRoas = roasUnwrapped.filter { roa in
            roa.nameUnwrapped == administrationRoute
        }

        guard let dose = filteredRoas.first?.dose else {
            return nil
        }
        return dose
    }
}
