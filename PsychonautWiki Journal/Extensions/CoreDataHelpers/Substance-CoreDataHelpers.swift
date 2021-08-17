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
        unsafeSubstanceInteractions?.allObjects as? [Substance] ?? []
    }

    var unsafeCategoryInteractionsUnwrapped: [Category] {
        unsafeCategoryInteractions?.allObjects as? [Category] ?? []
    }

    var unsafeGeneralInteractionsUnwrapped: [GeneralInteraction] {
        unsafeGeneralInteractions?.allObjects as? [GeneralInteraction] ?? []
    }

    var dangerousSubstanceInteractionsUnwrapped: [Substance] {
        dangerousSubstanceInteractions?.allObjects as? [Substance] ?? []
    }

    var dangerousCategoryInteractionsUnwrapped: [Category] {
        dangerousCategoryInteractions?.allObjects as? [Category] ?? []
    }

    var dangerousGeneralInteractionsUnwrapped: [GeneralInteraction] {
        dangerousGeneralInteractions?.allObjects as? [GeneralInteraction] ?? []
    }

    var administrationRoutesUnwrapped: [Roa.AdministrationRoute] {
        roasUnwrapped.map { roa in
            roa.nameUnwrapped
        }
    }

    var ingestionsUnwrappedSorted: [Ingestion] {
        let ingestions = ingestions?.allObjects as? [Ingestion] ?? []
        return ingestions.sorted { (ing1, ing2) -> Bool in
            ing1.timeUnwrapped < ing2.timeUnwrapped
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
