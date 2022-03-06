import Foundation
import SwiftUI

extension Experience: Comparable {
    public static func < (lhs: Experience, rhs: Experience) -> Bool {
        lhs.dateForSorting > rhs.dateForSorting
    }

    var dateForSorting: Date {
        sortedIngestionsUnwrapped.first?.timeUnwrapped ?? creationDateUnwrapped
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

    var timeOfFirstIngestion: Date? {
        sortedIngestionsUnwrapped.first?.timeUnwrapped
    }

    var isOver: Bool {
        guard sortedIngestionsUnwrapped.first != nil else {return false}
        guard let endOfGraph = Experience.getEndTime(for: sortedIngestionsUnwrapped) else {return false}
        return endOfGraph < Date()
    }

    static func getEndTime(for ingestions: [Ingestion]) -> Date? {
        guard let firstIngestion = ingestions.first else {return nil}
        // Initialize endOfGraphTime sensibly
        var endOfGraphTime = firstIngestion.timeUnwrapped
        for ingestion in ingestions {
            guard let duration = ingestion.substance?
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
