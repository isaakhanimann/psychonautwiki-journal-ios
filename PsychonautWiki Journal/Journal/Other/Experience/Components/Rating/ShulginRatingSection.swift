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
    let timeDisplayStyle: TimeDisplayStyle
    let firstIngestionTime: Date?

    @State private var isShowingSheet = false

    var body: some View {
        Section("Shulgin Rating") {
            ForEach(experience.ratingsSortedByTimeUnwrapped) { rating in
                NavigationLink {
                    EditRatingScreen(rating: rating)
                } label: {
                    RatingRow(
                        rating: rating,
                        timeDisplayStyle: timeDisplayStyle,
                        firstIngestionTime: firstIngestionTime
                    )
                }
            }
            Button {
                isShowingSheet.toggle()
            } label: {
                Label("Add Rating", systemImage: "plus")
            }
        }
        .sheet(isPresented: $isShowingSheet, content: {
            AddRatingScreen(experience: experience)
        })
    }
}

struct RatingRow: View {

    @ObservedObject var rating: ShulginRating
    let timeDisplayStyle: TimeDisplayStyle
    let firstIngestionTime: Date?

    var body: some View {
        HStack {
            if timeDisplayStyle == .relativeToNow {
                Text(rating.timeUnwrapped, style: .relative) + Text(" ago")
            } else if let firstIngestionTime, timeDisplayStyle == .relativeToStart {
                Text(DateDifference.formatted(DateDifference.between(firstIngestionTime, and: rating.timeUnwrapped)))
            } else {
                Text(rating.timeUnwrapped, style: .time)
            }
            Spacer()
            Text(rating.optionUnwrapped.stringRepresentation)
        }
    }
}
