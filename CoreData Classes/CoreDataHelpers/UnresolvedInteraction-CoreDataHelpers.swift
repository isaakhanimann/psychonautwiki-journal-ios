import Foundation

extension UnresolvedInteraction: Comparable {
    public static func < (lhs: UnresolvedInteraction, rhs: UnresolvedInteraction) -> Bool {
        lhs.nameUnwrapped < rhs.nameUnwrapped
    }

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var uncertainSubstancesUnwrapped: [Substance] {
        (unsafeSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var unsafeSubstancesUnwrapped: [Substance] {
        (unsafeSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var dangerousSubstancesUnwrapped: [Substance] {
        (dangerousSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

}
