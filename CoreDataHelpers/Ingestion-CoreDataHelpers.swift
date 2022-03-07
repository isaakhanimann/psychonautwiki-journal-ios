import Foundation
import SwiftUI
import CoreData

extension Ingestion: Comparable {
    public static func < (lhs: Ingestion, rhs: Ingestion) -> Bool {
        lhs.timeUnwrapped < rhs.timeUnwrapped
    }

    enum IngestionColor: String, CaseIterable {
        case blue, green, orange, pink, purple, red, yellow
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

    var administrationRouteUnwrapped: Roa.AdministrationRoute {
        Roa.AdministrationRoute(rawValue: administrationRoute ?? "oral") ?? .oral
    }

    var doseUnwrapped: Double {
        dose
    }

    var colorUnwrapped: IngestionColor {
            IngestionColor(rawValue: color ?? "purple") ?? IngestionColor.purple
    }

    var swiftUIColorUnwrapped: Color {
        Color.from(ingestionColor: colorUnwrapped)
    }

    var unitsUnwrapped: String {
        units ?? ""
    }

    var doseInfoString: String {
        return doseUnwrapped.cleanString + " " + unitsUnwrapped
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
        guard let minMax = doseTypesUnwrapped.minAndMaxRangeForGraph else { return defaultWeight }
        if doseUnwrapped <= minMax.min {
            return 0
        } else if doseUnwrapped >= minMax.max {
            return 1
        } else {
            let doseRelative = doseUnwrapped - minMax.min
            let rangeLength = minMax.max - minMax.min
            return Double(doseRelative / rangeLength)
        }
    }

    var endTime: Date {
        let defaultEnd = timeUnwrapped.addingTimeInterval(5*60*60)
        guard let durations = substance?.getDuration(for: administrationRouteUnwrapped) else {return defaultEnd}
        guard let onset = durations.onset?.oneValue(at: 0.5) else {return defaultEnd}
        guard let comeup = durations.comeup?.oneValue(at: 0.5) else {return defaultEnd}
        guard let peak = durations.peak?.oneValue(at: horizontalWeight) else {return defaultEnd}
        guard let offset = durations.offset?.oneValue(at: horizontalWeight) else {return defaultEnd}
        let totalDuration = onset
            + comeup
            + peak
            + offset
        return timeUnwrapped.addingTimeInterval(totalDuration)
    }

    var canTimeLineBeDrawn: Bool {
        guard let substanceUnwrap = substance else {return false}
        guard let duration = substanceUnwrap.getDuration(for: administrationRouteUnwrapped) else {return false}
        return duration.isFullTimeLineDefined
    }
}
