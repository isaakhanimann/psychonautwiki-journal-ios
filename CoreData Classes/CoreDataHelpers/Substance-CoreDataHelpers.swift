import Foundation
import CoreData

extension Substance {

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var roasUnwrapped: [Roa] {
        roas?.allObjects as? [Roa] ?? []
    }

    var unsafeSubstanceInteractionsUnwrapped: [Substance] {
        unsafeSubstances?.allObjects as? [Substance] ?? []
    }

    var unsafeGeneralInteractionsUnwrapped: [UnresolvedInteraction] {
        unsafeUnresolved?.allObjects as? [UnresolvedInteraction] ?? []
    }

    var dangerousSubstanceInteractionsUnwrapped: [Substance] {
        dangerousSubstances?.allObjects as? [Substance] ?? []
    }

    var dangerousGeneralInteractionsUnwrapped: [UnresolvedInteraction] {
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
