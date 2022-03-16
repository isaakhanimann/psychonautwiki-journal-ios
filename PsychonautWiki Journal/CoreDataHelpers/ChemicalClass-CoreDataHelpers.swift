import Foundation

extension ChemicalClass: Comparable {
    public static func < (lhs: ChemicalClass, rhs: ChemicalClass) -> Bool {
        lhs.nameUnwrapped < rhs.nameUnwrapped
    }

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var substancesUnwrapped: [Substance] {
        (substances?.allObjects as? [Substance] ?? []).sorted()
    }

    private var uncertainSubstancesUnwrapped: [Substance] {
        uncertainSubstances?.allObjects as? [Substance] ?? []
    }

    private var unsafeSubstancesUnwrapped: [Substance] {
        unsafeSubstances?.allObjects as? [Substance] ?? []
    }

    private var dangerousSubstancesUnwrapped: [Substance] {
        dangerousSubstances?.allObjects as? [Substance] ?? []
    }

    var crossToleranceUnwrapped: [Substance] {
        (crossTolerance?.allObjects as? [Substance] ?? []).sorted()
    }

    func containsSubstance(substance: Substance) -> Bool {
        substancesUnwrapped.contains(substance)
    }
}

extension ChemicalClass: SubstanceInteractable {

    var dangerousSubstancesToShow: [Substance] {
        dangerousSubstancesUnwrapped
    }

    var unsafeSubstancesToShow: [Substance] {
        unsafeSubstancesUnwrapped.filter { sub in
            !dangerousSubstancesUnwrapped.contains(sub)
        }
    }
    var uncertainSubstancesToShow: [Substance] {
        uncertainSubstancesUnwrapped.filter { sub in
            !dangerousSubstancesUnwrapped.contains(sub) && !unsafeSubstancesUnwrapped.contains(sub)
        }
    }
}
