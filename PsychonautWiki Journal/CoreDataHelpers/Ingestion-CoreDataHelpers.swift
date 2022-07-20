import Foundation
import SwiftUI
import CoreData

extension Ingestion: Comparable {
    public static func < (lhs: Ingestion, rhs: Ingestion) -> Bool {
        lhs.timeUnwrapped < rhs.timeUnwrapped
    }

    var timeUnwrapped: Date {
        time ?? Date()
    }

    var timeUnwrappedAsString: String {
        timeUnwrapped.asTimeString
    }

    var substanceNameUnwrapped: String {
        substanceName ?? "Unknown"
    }

    var administrationRouteUnwrapped: AdministrationRoute {
        AdministrationRoute(rawValue: administrationRoute ?? "oral") ?? .oral
    }

    var doseUnwrapped: Double? {
        if dose == 0 {
            return nil
        } else {
            return dose
        }
    }

    var unitsUnwrapped: String? {
        if let unwrap = units, unwrap != "" {
            return unwrap
        }
        return nil
    }

    var doseInfoString: String {
        guard let doseUnwrapped = doseUnwrapped,
              let unitsUnwrap = unitsUnwrapped else {
            return "Unknown Dose"
        }
        return doseUnwrapped.formatted() + " " + unitsUnwrap
    }

    var substanceColor: SubstanceColor {
        let fetchRequest = SubstanceCompanion.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(
            format: "substanceName = %@", substanceNameUnwrapped
        )
        let maybeColor = try? PersistenceController.shared.viewContext.fetch(fetchRequest).first?.color
        return maybeColor ?? SubstanceColor.purple
    }
}
