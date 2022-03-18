import Foundation
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

    var sortedIngestionsToDraw: [Ingestion] {
        sortedIngestionsUnwrapped.filter { ing in
            ing.canTimeLineBeDrawn
        }
    }

    var ingestionColors: [Color] {
        var colors = [Color]()
        for ingestion in sortedIngestionsUnwrapped {
            colors.append(ingestion.swiftUIColorUnwrapped)
        }
        return colors
    }

    var usedSubstanceNames: String {
        var names = sortedIngestionsUnwrapped.map { ingestion in
            ingestion.substanceName ?? "Unknown"
        }
        names = names.uniqued()
        guard !names.isEmpty else {return ""}
        var result = names.reduce("") { intermediateResult, name in
            intermediateResult + "\(name), "
        }
        result.removeLast(2)
        return result
    }

    var ingestionsWithDistinctSubstances: [Ingestion] {
        sortedIngestionsUnwrapped.reduce([]) { partialResult, ing in
            let resultSubs = partialResult.map { $0.substance }
            var resultIngs = partialResult
            if !resultSubs.contains(ing.substance) {
                resultIngs.append(ing)
            }
            return resultIngs
        }
    }
}
