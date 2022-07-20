import SwiftUI

extension Experience: Comparable {
    public static func < (lhs: Experience, rhs: Experience) -> Bool {
        lhs.dateForSorting > rhs.dateForSorting
    }

    var dateForSorting: Date {
        timeOfFirstIngestion ?? creationDateUnwrapped
    }

    var timeOfFirstIngestion: Date? {
        sortedIngestionsUnwrapped.first?.timeUnwrapped
    }

    var year: Int {
        Calendar.current.component(.year, from: dateForSorting)
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
            colors.append(ingestion.swiftUIColorUnwrapped)
        }
        return colors
    }

    var distinctUsedSubstanceNames: [String] {
        sortedIngestionsUnwrapped.map { ing in
            ing.substanceNameUnwrapped
        }.uniqued()
    }
}
