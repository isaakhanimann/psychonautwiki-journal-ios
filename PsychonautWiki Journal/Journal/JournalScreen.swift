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

    @Binding var searchText: String
    @Binding var isSearchPresented: Bool
    @Binding var isFavoriteFilterEnabled: Bool

    @State private var isTimeRelative = false

    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

    var body: some View {
        FabPosition {
            if !isSearchPresented {
                Button {
                    Navigator.shared.showAddIngestionFullScreenCover()
                } label: {
                    Label("New Ingestion", systemImage: "plus").labelStyle(FabLabelStyle())
                }
            }
        } screen: {
            ExperiencesList(
                searchText: searchText,
                isFavoriteFilterEnabled: isFavoriteFilterEnabled,
                isTimeRelative: isTimeRelative
            )
            .scrollDismissesKeyboard(.interactively)
            .modify {
                if #available(iOS 17.0, *) {
                    $0.searchable(text: $searchText, isPresented: $isSearchPresented, prompt: "Search experiences")
                } else {
                    $0.searchable(text: $searchText, prompt: "Search experiences")
                }
            }
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

extension View {
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
