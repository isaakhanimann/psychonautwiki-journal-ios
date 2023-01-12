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

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ExperiencesList(viewModel: viewModel)
            .optionalScrollDismissesKeyboard()
            .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
            .disableAutocorrection(true)
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isFavoriteFilterEnabled.toggle()
                    } label: {
                        if viewModel.isFavoriteFilterEnabled {
                            Label("Don't Filter Favorites", systemImage: "star.fill")
                        } else {
                            Label("Filter Favorites", systemImage: "star")
                        }
                    }
                    if #available(iOS 16, *) {
                        NavigationLink {
                            StatsScreen()
                        } label: {
                            Label("Stats", systemImage: "chart.bar")
                        }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        viewModel.isShowingAddIngestionSheet.toggle()
                    } label: {
                        Label("New Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                    }.fullScreenCover(isPresented: $viewModel.isShowingAddIngestionSheet) {
                        ChooseSubstanceScreen()
                    }
                    Spacer()
                    Button {
                        viewModel.isTimeRelative.toggle()
                    } label: {
                        if viewModel.isTimeRelative {
                            Label("Show Absolute Time", systemImage: "timer.circle.fill")
                        } else {
                            Label("Show Relative Time", systemImage: "timer.circle")
                        }
                    }
                }
            }
    }
}
