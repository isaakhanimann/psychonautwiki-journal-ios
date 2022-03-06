import Foundation

extension UnresolvedInteraction: Comparable {
    public static func < (lhs: UnresolvedInteraction, rhs: UnresolvedInteraction) -> Bool {
        lhs.nameUnwrapped < rhs.nameUnwrapped
    }

    var nameUnwrapped: String {
        name ?? "Unknown"
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

}

extension UnresolvedInteraction: SubstanceInteractable {

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
