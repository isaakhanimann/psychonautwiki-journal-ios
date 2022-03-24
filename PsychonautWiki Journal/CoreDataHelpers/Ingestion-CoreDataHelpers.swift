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

    var substance: Substance? {
        guard let substanceNameUnwrapped = substanceName else {return nil}
        let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
        let pred = NSPredicate(format: "name == %@", substanceNameUnwrapped)
        fetchRequest.predicate = pred
        return try? self.managedObjectContext?.fetch(fetchRequest).first
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

    var colorUnwrapped: IngestionColor {
            IngestionColor(rawValue: color ?? "purple") ?? IngestionColor.purple
    }

    var swiftUIColorUnwrapped: Color {
        colorUnwrapped.swiftUIColor
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

    // Get value between 0 and 1
    // 0 means that ingestion dose is threshold or below
    // 1 means that ingestion dose is heavy or above
    // values in between are interpolated linearly
    var horizontalWeight: Double {
        let defaultWeight = 0.5
        guard let doseTypesUnwrapped = substance?.getDose(for: administrationRouteUnwrapped) else {
            return defaultWeight
        }
        guard unitsUnwrapped == doseTypesUnwrapped.unitsUnwrapped else {
            return defaultWeight
        }
        guard let minMax = doseTypesUnwrapped.minAndMaxRangeForGraph else { return defaultWeight }
        guard let doseDoubleUnwrap = doseUnwrapped else {return defaultWeight}
        if doseDoubleUnwrap <= minMax.min {
            return 0
        } else if doseDoubleUnwrap >= minMax.max {
            return 1
        } else {
            let doseRelative = doseDoubleUnwrap - minMax.min
            let rangeLength = minMax.max - minMax.min
            return Double(doseRelative / rangeLength)
        }
    }

    var canTimeLineBeDrawn: Bool {
        guard let substanceUnwrap = substance else {return false}
        guard let duration = substanceUnwrap.getDuration(for: administrationRouteUnwrapped) else {return false}
        return duration.isFullTimeLineDefined
    }

    func getInteraction(with otherSubstance: Substance) -> InteractionType {
        guard let substanceUnwrapped = substance else { return .none }
        return substanceUnwrapped.getInteraction(with: otherSubstance)
    }

    func getInteraction(with otherSubstances: [Substance]) -> InteractionType {
        guard let substanceUnwrapped = substance else { return .none }
        let interactions = otherSubstances.map { sub in
            substanceUnwrapped.getInteraction(with: sub)
        }
        if interactions.contains(.dangerous) {
            return .dangerous
        } else if interactions.contains(.unsafe) {
            return .unsafe
        } else if interactions.contains(.uncertain) {
            return .uncertain
        } else {
            return .none
        }
    }
}
