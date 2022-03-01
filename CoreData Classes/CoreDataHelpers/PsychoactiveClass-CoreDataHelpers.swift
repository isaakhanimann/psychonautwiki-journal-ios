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

    var uncertainSubstancesUnwrapped: [Substance] {
        (uncertainSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var unsafeSubstancesUnwrapped: [Substance] {
        (unsafeSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var dangerousSubstancesUnwrapped: [Substance] {
        (dangerousSubstances?.allObjects as? [Substance] ?? []).sorted()
    }

    var crossToleranceUnwrapped: [Substance] {
        (crossTolerance?.allObjects as? [Substance] ?? []).sorted()
    }
}
