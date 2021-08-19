import Foundation
import SwiftUI

extension Experience {

    var creationDateUnwrapped: Date {
        creationDate ?? Date()
    }

    var dateToSortBy: Date {
        sortedIngestionsUnwrapped.first?.timeUnwrapped ?? creationDateUnwrapped
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
        let ingestions = ingestions?.allObjects as? [Ingestion] ?? []
        return ingestions.sorted { (ing1, ing2) -> Bool in
            ing1.timeUnwrapped < ing2.timeUnwrapped
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
            ingestion.substanceCopy!.nameUnwrapped
        }
        names = names.uniqued()

        guard !names.isEmpty else {return ""}

        var result = names.reduce("") { intermediateResult, name in
            intermediateResult + "\(name), "
        }
        result.removeLast(2)

        return result
    }

    var timeOfFirstIngestion: Date? {
        sortedIngestionsUnwrapped.first?.timeUnwrapped
    }

    var isActive: Bool {
        guard sortedIngestionsUnwrapped.first != nil else {return false}

        let endOfGraph = HelperMethods.getEndOfGraphTime(
            ingestions: sortedIngestionsUnwrapped,
            shouldAddTimeAtEnd: true
        )

        return endOfGraph >= Date()
    }
}
