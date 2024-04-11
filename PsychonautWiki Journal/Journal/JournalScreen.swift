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

struct JournalScreen: View {

    @State private var searchText = ""
    @State private var isTimeRelative = false
    @State private var isFavoriteFilterEnabled = false

    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

    @EnvironmentObject var navigator: Navigator

    var body: some View {
        FabPosition {
            Button {
                navigator.showAddIngestionFullScreenCover()
            } label: {
                Label("New Ingestion", systemImage: "plus").labelStyle(FabLabelStyle())
            }
        } screen: {
            ExperiencesList(
                searchText: searchText,
                isFavoriteFilterEnabled: isFavoriteFilterEnabled,
                isTimeRelative: isTimeRelative
            )
            .scrollDismissesKeyboard(.interactively)
            .searchable(text: $searchText, prompt: "Search by title or substance")
            .disableAutocorrection(true)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                favoriteButton
                Menu {
                    Button {
                        isTimeRelative = false
                    } label: {
                        let option = SaveableTimeDisplayStyle.regular
                        if isTimeRelative {
                            Text(option.text)
                        } else {
                            Label(option.text, systemImage: "checkmark")
                        }
                    }
                    Button {
                        isTimeRelative = true
                    } label: {
                        let option = SaveableTimeDisplayStyle.relativeToNow
                        if isTimeRelative {
                            Label(option.text, systemImage: "checkmark")
                        } else {
                            Text(option.text)
                        }
                    }
                } label: {
                    Label("Time Display", systemImage: "timer")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: GlobalNavigationDestination.calendar) {
                    Label("Calendar", systemImage: "calendar")
                }
            }
        }
        .navigationTitle("Journal")
    }

    private var favoriteButton: some View {
        Button {
            isFavoriteFilterEnabled.toggle()
        } label: {
            if isFavoriteFilterEnabled {
                Label("Don't Filter Favorites", systemImage: "star.fill")
            } else {
                Label("Filter Favorites", systemImage: "star")
            }
        }
    }
}
