import Foundation
import CoreData

extension Substance {

    var nameUnwrapped: String {
        name ?? "Unknown"
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
        crossToleranceSubstances?.allObjects as? [Substance] ?? []
    }

    var crossTolerancePsychoactivesUnwrapped: [PsychoactiveClass] {
        crossTolerancePsychoactives?.allObjects as? [PsychoactiveClass] ?? []
    }

    var crossToleranceChemicalsUnwrapped: [ChemicalClass] {
        crossToleranceChemicals?.allObjects as? [ChemicalClass] ?? []
    }

    var uncertainSubstancesUnwrapped: [Substance] {
        uncertainSubstances?.allObjects as? [Substance] ?? []
    }

    var uncertainPsychoactivesUnwrapped: [PsychoactiveClass] {
        uncertainPsychoactives?.allObjects as? [PsychoactiveClass] ?? []
    }

    var uncertainChemicalsUnwrapped: [ChemicalClass] {
        uncertainChemicals?.allObjects as? [ChemicalClass] ?? []
    }

    var uncertainUnresolvedUnwrapped: [UnresolvedInteraction] {
        uncertainUnresolved?.allObjects as? [UnresolvedInteraction] ?? []
    }

    var unsafeSubstancesUnwrapped: [Substance] {
        unsafeSubstances?.allObjects as? [Substance] ?? []
    }

    var unsafePsychoactivesUnwrapped: [PsychoactiveClass] {
        unsafePsychoactives?.allObjects as? [PsychoactiveClass] ?? []
    }

    var unsafeChemicalsUnwrapped: [ChemicalClass] {
        unsafeChemicals?.allObjects as? [ChemicalClass] ?? []
    }

    var unsafeUnresolvedUnwrapped: [UnresolvedInteraction] {
        unsafeUnresolved?.allObjects as? [UnresolvedInteraction] ?? []
    }

    var dangerousSubstancesUnwrapped: [Substance] {
        dangerousSubstances?.allObjects as? [Substance] ?? []
    }

    var dangerousPsychoactivesUnwrapped: [PsychoactiveClass] {
        dangerousPsychoactives?.allObjects as? [PsychoactiveClass] ?? []
    }

    var dangerousChemicalsUnwrapped: [ChemicalClass] {
        dangerousChemicals?.allObjects as? [ChemicalClass] ?? []
    }

    var dangerousUnresolvedUnwrapped: [UnresolvedInteraction] {
        dangerousUnresolved?.allObjects as? [UnresolvedInteraction] ?? []
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
