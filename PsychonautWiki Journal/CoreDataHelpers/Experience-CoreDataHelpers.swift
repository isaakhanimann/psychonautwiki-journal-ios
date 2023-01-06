import SwiftUI

extension Experience: Comparable {
    public static func < (lhs: Experience, rhs: Experience) -> Bool {
        lhs.sortDateUnwrapped > rhs.sortDateUnwrapped
    }

    var sortDateUnwrapped: Date {
        sortDate ?? creationDateUnwrapped
    }

    var year: Int {
        Calendar.current.component(.year, from: sortDateUnwrapped)
    }

    var creationDateUnwrapped: Date {
        creationDate ?? Date()
    }

    var titleUnwrapped: String {
        title ?? creationDateUnwrappedString
    }

    var textUnwrapped: String {
        text ?? ""
    }

    var creationDateUnwrappedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: creationDateUnwrapped)
    }

    var sortedIngestionsUnwrapped: [Ingestion] {
        (ingestions?.allObjects as? [Ingestion] ?? []).sorted()
    }

    var ingestionColors: [Color] {
        var colors = [Color]()
        for ingestion in sortedIngestionsUnwrapped {
            colors.append(ingestion.substanceColor.swiftUIColor)
        }
        return colors
    }

    var distinctUsedSubstanceNames: [String] {
        sortedIngestionsUnwrapped.map { ing in
            ing.substanceNameUnwrapped
        }.uniqued()
    }

    var isCurrent: Bool {
        let twelveHours: TimeInterval = 12*60*60
        if let lastIngestionTime = sortedIngestionsUnwrapped.last?.time,
           Date().timeIntervalSinceReferenceDate - lastIngestionTime.timeIntervalSinceReferenceDate < twelveHours {
            return true
        } else {
            return false
        }
    }
}
