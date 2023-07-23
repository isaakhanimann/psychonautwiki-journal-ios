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
    @ObservedObject var viewModel: ExperienceScreen.ViewModel
    let timeDisplayStyle: TimeDisplayStyle
    let firstIngestionTime: Date?
    let addRating: () -> Void

    var body: some View {
        Section {
            ForEach(experience.ratingsWithTimeSorted) { rating in
                NavigationLink {
                    EditRatingScreen(rating: rating)
                } label: {
                    let isRatingHidden = viewModel.hiddenRatings.contains(rating.id)
                    HStack(alignment: .center) {
                        if isRatingHidden {
                            Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                        }
                        RatingRow(
                            rating: rating,
                            timeDisplayStyle: timeDisplayStyle,
                            firstIngestionTime: firstIngestionTime
                        )
                    }
                    .swipeActions(edge: .leading) {
                        if isRatingHidden {
                            Button {
                                viewModel.showRating(id: rating.id)
                            } label: {
                                Label("Show", systemImage: "eye.fill").labelStyle(.iconOnly)
                            }
                        } else {
                            Button {
                                viewModel.hideRating(id: rating.id)
                            } label: {
                                Label("Hide", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            PersistenceController.shared.viewContext.delete(rating)
                            PersistenceController.shared.saveViewContext()
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            if let overallRating = experience.overallRating {
                NavigationLink {
                    EditOverallRatingScreen(rating: overallRating)
                } label: {
                    RatingRow(
                        rating: overallRating,
                        timeDisplayStyle: timeDisplayStyle,
                        firstIngestionTime: firstIngestionTime
                    ).swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            PersistenceController.shared.viewContext.delete(overallRating)
                            PersistenceController.shared.saveViewContext()
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }

            }
            if experience.isCurrent {
                Button(action: addRating) {
                    Label("Add Rating", systemImage: "plus")
                }
            }
        } header: {
            HStack {
                Text("Shulgin Rating")
                Spacer()
                if !experience.isCurrent {
                    Button(action: addRating) {
                        Label("Add Rating", systemImage: "plus").labelStyle(.iconOnly)
                    }
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
                    Text(DateDifference.formatted(DateDifference.between(firstIngestionTime, and: ratingTime)))
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
