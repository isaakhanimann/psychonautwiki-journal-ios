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

struct ExperiencesList: View {
    let isFavoriteFilterEnabled: Bool
    let isTimeRelative: Bool

    init(searchText: String, isFavoriteFilterEnabled: Bool, isTimeRelative: Bool) {
        self.isFavoriteFilterEnabled = isFavoriteFilterEnabled
        self.isTimeRelative = isTimeRelative
        let predicateFavorite = NSPredicate(
            format: "isFavorite == %@",
            NSNumber(value: true)
        )
        let predicateTitle = NSPredicate(
            format: "title CONTAINS[cd] %@",
            searchText as CVarArg
        )
        let predicateNotes = NSPredicate(
            format: "text CONTAINS[cd] %@",
            searchText as CVarArg
        )
        let predicateConsumer = NSPredicate(
            format: "%K.%K CONTAINS[cd] %@",
            #keyPath(Experience.ingestions),
            #keyPath(Ingestion.consumerName),
            searchText as CVarArg
        )
        let predicateSubstance = NSPredicate(
            format: "%K.%K CONTAINS[cd] %@",
            #keyPath(Experience.ingestions),
            #keyPath(Ingestion.substanceName),
            searchText as CVarArg
        )
        var experiencePredicate: NSPredicate?
        let orPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: [predicateTitle, predicateSubstance, predicateNotes, predicateConsumer])
        if isFavoriteFilterEnabled {
            if searchText.isEmpty {
                experiencePredicate = predicateFavorite
            } else {
                experiencePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFavorite, orPredicates])
            }
        } else {
            if searchText.isEmpty {
                experiencePredicate = nil
            } else {
                experiencePredicate = orPredicates
            }
        }
        _fetchedExperiences = FetchRequest<Experience>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false)],
            predicate: experiencePredicate)
    }

    @FetchRequest var fetchedExperiences: FetchedResults<Experience>

    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List(fetchedExperiences) { experience in
                ExperienceRow(experience: experience, isTimeRelative: isTimeRelative)
            }
            .listStyle(.plain)
            if fetchedExperiences.isEmpty {
                if isSearching {
                    Text("No experiences match the search")
                        .foregroundColor(.secondary)
                } else if isFavoriteFilterEnabled {
                    Text("No favorites match the search")
                        .foregroundColor(.secondary)
                } else {
                    Text("No ingestions yet")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
