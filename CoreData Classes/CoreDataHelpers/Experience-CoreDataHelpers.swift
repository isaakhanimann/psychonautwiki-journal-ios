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
            ingestion.substanceCopy?.nameUnwrapped ?? "Unknown"
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

        guard let endOfGraph = Experience.getEndTime(for: sortedIngestionsUnwrapped) else {return false}

        return endOfGraph >= Date()
    }

    static func getEndTime(for ingestions: [Ingestion]) -> Date? {

        guard let firstIngestion = ingestions.first else {return nil}

        // Initialize endOfGraphTime sensibly
        var endOfGraphTime = firstIngestion.timeUnwrapped
        for ingestion in ingestions {
            guard let duration = ingestion.substanceCopy?
                    .getDuration(for: ingestion.administrationRouteUnwrapped) else {return nil}
            guard let onset = duration.onset?.maxSec else {return nil}
            guard let comeup = duration.comeup?.maxSec else {return nil}
            guard let peak = duration.peak?.maxSec else {return nil}
            guard let offset = duration.offset?.maxSec else {return nil}

            // Choose the latest possible offset to make sure that the graph fits all ingestions
            let offsetEnd = onset
                + comeup
                + peak
                + offset

            let maybeNewEndTime = ingestion.timeUnwrapped.addingTimeInterval(offsetEnd)
            if endOfGraphTime.distance(to: maybeNewEndTime) > 0 {
                endOfGraphTime = maybeNewEndTime
            }
        }

        return endOfGraphTime
    }
}
