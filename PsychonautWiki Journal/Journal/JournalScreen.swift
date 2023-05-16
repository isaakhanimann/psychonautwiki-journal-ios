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
import StoreKit

struct JournalScreen: View {

    @StateObject var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @AppStorage("openUntilRatedCount") var openUntilRatedCount: Int = 0

    var body: some View {
        NavigationView {
            AddIngestionFab {
                viewModel.isShowingAddIngestionSheet.toggle()
            } screen: {
                screen
            }
            .fullScreenCover(isPresented: $viewModel.isShowingAddIngestionSheet) {
                ChooseSubstanceScreen()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsScreen()) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    favoriteButton
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
            .navigationTitle("Journal")
        }
    }

    private var newIngestionButton: some View {
        Button {
            viewModel.isShowingAddIngestionSheet.toggle()
        } label: {
            Label("New Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
        }
    }

    private var favoriteButton: some View {
        Button {
            viewModel.isFavoriteFilterEnabled.toggle()
        } label: {
            if viewModel.isFavoriteFilterEnabled {
                Label("Don't Filter Favorites", systemImage: "star.fill")
            } else {
                Label("Filter Favorites", systemImage: "star")
            }
        }
    }

    private var screen: some View {
        ExperiencesList(viewModel: viewModel)
            .optionalScrollDismissesKeyboard()
            .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
            .disableAutocorrection(true)
            .onChange(of: viewModel.searchText, perform: { newValue in
                viewModel.setupFetchRequestPredicateAndFetch()
            })
            .onChange(of: viewModel.isFavoriteFilterEnabled, perform: { newValue in
                viewModel.setupFetchRequestPredicateAndFetch()
            })
            .task {
                maybeRequestAppRating()
            }
    }

    private func maybeRequestAppRating() {
        if #available(iOS 16.2, *) {
            if openUntilRatedCount < 10 {
                openUntilRatedCount += 1
            } else if openUntilRatedCount == 10 {
                if isEyeOpen && viewModel.previousExperiences.count > 5 {
                    if let windowScene = UIApplication.shared.currentWindow?.windowScene {
                        SKStoreReviewController.requestReview(in: windowScene)
                    }
                    openUntilRatedCount += 1
                }
            }
        }
    }
}
