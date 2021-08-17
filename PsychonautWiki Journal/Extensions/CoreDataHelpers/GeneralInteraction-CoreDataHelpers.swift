import Foundation

extension GeneralInteraction {
    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var unsafeSubstanceInteractionsUnwrapped: [Substance] {
        unsafeSubstanceInteractions?.allObjects as? [Substance] ?? []
    }

    var dangerousSubstanceInteractionsUnwrapped: [Substance] {
        dangerousSubstanceInteractions?.allObjects as? [Substance] ?? []
    }

}
