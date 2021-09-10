import Foundation
import SwiftUI

extension Ingestion {

    enum IngestionColor: String, CaseIterable {
        case blue, gray, green, orange, pink, purple, red, yellow
    }

    var timeUnwrapped: Date {
        time ?? Date()
    }

    var timeUnwrappedAsString: String {
        timeUnwrapped.asTimeString
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

    var doseInfoString: String {
        guard let substanceUnwrapped = substanceCopy else { return "" }
        let info = doseUnwrapped.cleanString
        let unitsUnwrapped = substanceUnwrapped.getDose(
            for: administrationRouteUnwrapped
        )?.units ?? ""
        return info.appending(" \(unitsUnwrapped)")
    }

    // Get value between 0 and 1
    // 0 means that ingestion dose is threshold or below
    // 1 means that ingestion dose is heavy or above
    // values in between are interpolated linearly
    var horizontalWeight: Double {
        let defaultWeight = 0.5

        guard let doseTypesUnwrapped = substanceCopy!.getDose(for: administrationRouteUnwrapped) else {
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
            return doseRelative / rangeLength
        }
    }
}
