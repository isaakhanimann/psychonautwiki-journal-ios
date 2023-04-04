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
    @State private var isShowingSheet = false
    @State private var sheet: SheetOption? = nil

    enum SheetOption: Identifiable {
        var id: String {
            switch(self) {
            case .addRating:
                return "addRating"
            case let .editRating(rating):
                return rating.creationDateUnwrapped.description
            }
        }

        case addRating, editRating(ShulginRating)
    }

    var body: some View {
        Section("Shulgin Rating") {
            ForEach(experience.sortedRatingsUnwrapped) { rating in
                Button {
                    sheet = .editRating(rating)
                } label: {
                    HStack {
                        Text(rating.timeUnwrapped, style: .time)
                        Spacer()
                        Text(rating.optionUnwrapped.stringRepresentation)
                    }
                }
            }
            Button {
                sheet = .addRating
            } label: {
                Label("Add Rating", systemImage: "plus")
            }
        }.sheet(item: $sheet) { option in
            switch(option) {
            case .addRating:
                AddRatingScreen(experience: experience)
            case let .editRating(rating):
                EditRatingScreen(rating: rating)
            }
        }
    }
}


