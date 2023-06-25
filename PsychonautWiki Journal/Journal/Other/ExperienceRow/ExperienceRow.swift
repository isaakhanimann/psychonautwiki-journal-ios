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
import Combine


struct ExperienceRow: View {

    @ObservedObject var experience: Experience
    let isTimeRelative: Bool

    var body: some View {
        NavigationLink(
            destination: ExperienceScreen(experience: experience)
        ) {
            Group {
                if let location = experience.location {
                    ExperienceRowObservedLocation(
                        experience: experience,
                        location: location,
                        isTimeRelative: isTimeRelative,
                        rating: experience.maxRating
                    )
                } else {
                    ExperienceRowContent(
                        ingestionColors: experience.ingestionColors,
                        title: experience.titleUnwrapped,
                        distinctSubstanceNames: experience.distinctUsedSubstanceNames,
                        sortDate: experience.sortDateUnwrapped,
                        isFavorite: experience.isFavorite,
                        isTimeRelative: isTimeRelative,
                        locationName: nil,
                        rating: experience.overallRating?.optionUnwrapped ?? experience.maxRating
                    )
                }
            }
            .swipeActions(allowsFullSwipe: false) {
                Button(role: .destructive) {
                    if #available(iOS 16.2, *) {
                        if experience.isCurrent {
                            Task {
                                await ActivityManager.shared.stopActivity(
                                    everythingForEachLine: getEverythingForEachLine(from: experience.sortedIngestionsUnwrapped),
                                    everythingForEachRating: experience.ratingsWithTimeSorted.map({ shulgin in
                                        EverythingForOneRating(time: shulgin.timeUnwrapped, option: shulgin.optionUnwrapped)
                                    })
                                )
                            }
                        }
                    }
                    PersistenceController.shared.viewContext.delete(experience)
                    PersistenceController.shared.saveViewContext()
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
        }
    }
}

struct ExperienceRowObservedLocation: View {
    @ObservedObject var experience: Experience
    @ObservedObject var location: ExperienceLocation
    let isTimeRelative: Bool
    let rating: ShulginRatingOption?

    var body: some View {
        ExperienceRowContent(
            ingestionColors: experience.ingestionColors,
            title: experience.titleUnwrapped,
            distinctSubstanceNames: experience.distinctUsedSubstanceNames,
            sortDate: experience.sortDateUnwrapped,
            isFavorite: experience.isFavorite,
            isTimeRelative: isTimeRelative,
            locationName: location.name,
            rating: rating
        )
    }
}

struct ExperienceRowContent: View {

    let ingestionColors: [Color]
    let title: String
    let distinctSubstanceNames: [String]
    let sortDate: Date
    let isFavorite: Bool
    let isTimeRelative: Bool
    let locationName: String?
    let rating: ShulginRatingOption?

    var body: some View {
        TimelineView(.everyMinute) { _ in
            HStack {
                ExperienceColorRectangle(colors: ingestionColors)
                Spacer().frame(width: 10)
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        Spacer()
                        if isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    HStack {
                        Group {
                            if distinctSubstanceNames.isEmpty {
                                Text("No substance")
                            } else {
                                Text(distinctSubstanceNames, format: .list(type: .and))
                            }
                        }.font(.subheadline)
                        Spacer()
                        if let rating {
                            Text(rating.stringRepresentation)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                    HStack {
                        ExperienceTimeText(time: sortDate, isTimeRelative: isTimeRelative)
                        Spacer()
                        if let locationName {
                            HStack(spacing: 2) {
                                Image(systemName: "mappin")
                                Text(locationName).lineLimit(1)
                            }
                        }
                    }
                    .foregroundColor(.secondary)
                    .font(.footnote)
                }
            }
        }
    }
}

struct ExperienceRowContent_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                ExperienceRowContent(
                    ingestionColors: [.blue, .pink],
                    title: "My slightly longer title",
                    distinctSubstanceNames: ["MDMA", "LSD"],
                    sortDate: Date() - 5 * 60 * 60 - 30,
                    isFavorite: true,
                    isTimeRelative: false,
                    locationName: "Longer location name",
                    rating: .threePlus
                )
                ExperienceRowContent(
                    ingestionColors: [.blue, .pink],
                    title: "My slightly longer title",
                    distinctSubstanceNames: ["MDMA", "LSD"],
                    sortDate: Date() - 5 * 60 * 60 - 30,
                    isFavorite: true,
                    isTimeRelative: false,
                    locationName: nil,
                    rating: .threePlus
                )
                ExperienceRowContent(
                    ingestionColors: [.blue, .pink, .purple, .yellow],
                    title: "My title",
                    distinctSubstanceNames: ["MDMA", "LSD", "Cocaine", "Amphetamine"],
                    sortDate: Date() - 5 * 60 * 60 - 30,
                    isFavorite: true,
                    isTimeRelative: true,
                    locationName: "Short location",
                    rating: .threePlus
                )
                ExperienceRowContent(
                    ingestionColors: [.blue, .pink],
                    title: "My title is not is a normal length",
                    distinctSubstanceNames: ["MDMA", "LSD"],
                    sortDate: Date() - 5 * 60 * 60 - 30,
                    isFavorite: true,
                    isTimeRelative: true,
                    locationName: nil,
                    rating: nil
                )
                ExperienceRowContent(
                    ingestionColors: [.blue, .pink],
                    title: "My title short",
                    distinctSubstanceNames: ["MDMA", "LSD"],
                    sortDate: Date() - 5 * 60 * 60 - 30,
                    isFavorite: true,
                    isTimeRelative: true,
                    locationName: "Home",
                    rating: nil
                )
                ExperienceRowContent(
                    ingestionColors: [],
                    title: "My title is not is a normal length",
                    distinctSubstanceNames: [],
                    sortDate: Date() - 5 * 60 * 60 - 30,
                    isFavorite: false,
                    isTimeRelative: false,
                    locationName: nil,
                    rating: .threePlus
                )
            }
        }.listStyle(.plain)
    }
}