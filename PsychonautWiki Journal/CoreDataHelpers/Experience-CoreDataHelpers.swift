// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

extension Experience: Comparable {
    public static func < (lhs: Experience, rhs: Experience) -> Bool {
        lhs.sortDateUnwrapped > rhs.sortDateUnwrapped
    }

    var sortDateUnwrapped: Date {
        sortedIngestionsUnwrapped.first?.time ?? sortDate ?? creationDateUnwrapped
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

    var ratingsUnwrapped: [ShulginRating] {
        ratings?.allObjects as? [ShulginRating] ?? []
    }

    var ratingsWithTimeSorted: [ShulginRating] {
        ratingsUnwrapped.filter({ rating in
            rating.time != nil
        }).sorted()
    }

    var maxRating: ShulginRatingOption? {
        ratingsUnwrapped.map { rating in
            rating.optionUnwrapped
        }.max()
    }

    var overallRating: ShulginRating? {
        ratingsUnwrapped.first { rating in
            rating.time == nil
        }
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
