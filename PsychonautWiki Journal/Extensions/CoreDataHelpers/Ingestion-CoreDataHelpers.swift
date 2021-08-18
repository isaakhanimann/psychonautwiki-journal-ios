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
}
