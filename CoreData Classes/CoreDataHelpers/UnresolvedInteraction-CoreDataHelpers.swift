import Foundation

extension UnresolvedInteraction {
    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var uncertainSubstancesUnwrapped: [Substance] {
        unsafeSubstances?.allObjects as? [Substance] ?? []
    }

    var unsafeSubstancesUnwrapped: [Substance] {
        unsafeSubstances?.allObjects as? [Substance] ?? []
    }

    var dangerousSubstancesUnwrapped: [Substance] {
        dangerousSubstances?.allObjects as? [Substance] ?? []
    }

}
