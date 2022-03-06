import Foundation

extension PsychoactiveClass: Comparable {
    public static func < (lhs: PsychoactiveClass, rhs: PsychoactiveClass) -> Bool {
        lhs.nameUnwrapped < rhs.nameUnwrapped
    }

    var nameUnwrapped: String {
        name ?? "Miscellaneous"
    }

    var substancesUnwrapped: [Substance] {
        (substances?.allObjects as? [Substance] ?? []).sorted()
    }

    private var uncertainSubstancesUnwrapped: [Substance] {
        (uncertainSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    private var unsafeSubstancesUnwrapped: [Substance] {
        (unsafeSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    private var dangerousSubstancesUnwrapped: [Substance] {
        (dangerousSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var crossToleranceUnwrapped: [Substance] {
        (crossTolerance?.allObjects as? [Substance] ?? []).sorted()
    }

    func containsSubstance(substance: Substance) -> Bool {
        substancesUnwrapped.contains(substance)
    }
}

extension PsychoactiveClass: SubstanceInteractable {

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
