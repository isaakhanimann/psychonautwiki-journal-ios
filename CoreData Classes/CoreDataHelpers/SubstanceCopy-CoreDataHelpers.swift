import Foundation
import CoreData

extension SubstanceCopy {

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var roasUnwrapped: [Roa] {
        roas?.allObjects as? [Roa] ?? []
    }

    var administrationRoutesUnwrapped: [Roa.AdministrationRoute] {
        roasUnwrapped.map { roa in
            roa.nameUnwrapped
        }
    }

    func getDuration(for administrationRoute: Roa.AdministrationRoute) -> DurationTypes? {
        let filteredRoas = roasUnwrapped.filter { roa in
            roa.nameUnwrapped == administrationRoute
        }

        guard let duration = filteredRoas.first?.durationTypes else {
            return nil
        }
        return duration
    }

    func getDose(for administrationRoute: Roa.AdministrationRoute) -> DoseTypes? {
        let filteredRoas = roasUnwrapped.filter { roa in
            roa.nameUnwrapped == administrationRoute
        }

        guard let dose = filteredRoas.first?.doseTypes else {
            return nil
        }
        return dose
    }
}
