// Copyright (c) 2023. Isaak Hanimann.
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

struct ShulginRatingSection: View {
    @ObservedObject var experience: Experience
    let hiddenRatings: [ObjectIdentifier]
    let showRating: (ObjectIdentifier) -> Void
    let hideRating: (ObjectIdentifier) -> Void
    let timeDisplayStyle: TimeDisplayStyle
    let firstIngestionTime: Date?

    enum SheetOption: Identifiable, Hashable {
        case editRegular(rating: ShulginRating)
        case editOverall(rating: ShulginRating)

        var id: Self {
            return self
        }
    }
    @State private var sheetToShow: SheetOption?

    var body: some View {
        Section("Shulgin Rating") {
            ForEach(experience.ratingsWithTimeSorted) { rating in
                Button(action: {
                    sheetToShow = .editRegular(rating: rating)
                }, label: {
                    let isRatingHidden = hiddenRatings.contains(rating.id)
                    HStack(alignment: .center) {
                        if isRatingHidden {
                            Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                        }
                        RatingRow(
                            rating: rating,
                            timeDisplayStyle: timeDisplayStyle,
                            firstIngestionTime: firstIngestionTime
                        )
                    }.foregroundColor(.primary)
                })
            }
            if let overallRating = experience.overallRating {
                Button(action: {
                    sheetToShow = .editOverall(rating: overallRating)
                }, label: {
                    RatingRow(
                        rating: overallRating,
                        timeDisplayStyle: timeDisplayStyle,
                        firstIngestionTime: firstIngestionTime
                    ).foregroundColor(.primary)
                })
            }
        }.sheet(item: $sheetToShow) { sheetOption in
            NavigationStack {
                switch sheetOption {
                case .editRegular(let rating):
                    let isHidden = Binding(
                        get: { hiddenRatings.contains(rating.id) },
                        set: { newIsHidden in
                            if newIsHidden {
                                hideRating(rating.id)
                            } else {
                                showRating(rating.id)
                            }
                        }
                    )
                    EditRatingScreen(rating: rating, isHidden: isHidden)
                case .editOverall(let rating):
                    EditOverallRatingScreen(rating: rating)
                }
            }
        }
    }
}

struct RatingRow: View {
    @ObservedObject var rating: ShulginRating
    let timeDisplayStyle: TimeDisplayStyle
    let firstIngestionTime: Date?

    var body: some View {
        HStack {
            if let ratingTime = rating.time {
                if timeDisplayStyle == .relativeToNow {
                    Text(ratingTime, style: .relative) + Text(" ago")
                } else if let firstIngestionTime, timeDisplayStyle == .relativeToStart {
                    Text("+ ") + Text(DateDifference.formatted(DateDifference.between(firstIngestionTime, and: ratingTime)))
                } else {
                    Text(ratingTime, format: Date.FormatStyle().hour().minute().weekday(.abbreviated))
                }
            } else {
                Text("Overall Rating")
            }
            Spacer()
            Text(rating.optionUnwrapped.stringRepresentation)
        }.font(.headline)
    }
}
