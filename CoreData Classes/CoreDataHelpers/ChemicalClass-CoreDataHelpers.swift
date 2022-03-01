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

    var uncertainSubstancesUnwrapped: [Substance] {
        uncertainSubstances?.allObjects as? [Substance] ?? []
    }

    var unsafeSubstancesUnwrapped: [Substance] {
        unsafeSubstances?.allObjects as? [Substance] ?? []
    }

    var dangerousSubstancesUnwrapped: [Substance] {
        dangerousSubstances?.allObjects as? [Substance] ?? []
    }

    var crossToleranceUnwrapped: [Substance] {
        (crossTolerance?.allObjects as? [Substance] ?? []).sorted()
    }
}
