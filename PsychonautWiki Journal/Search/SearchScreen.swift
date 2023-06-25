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

struct SearchScreen: View {

    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    SubstanceSearchBar(
                        text: $viewModel.searchText,
                        isFocused: $isSearchFocused,
                        allCategories: viewModel.allCategories,
                        toggleCategory: { cat in
                            viewModel.toggleCategory(category: cat)
                        },
                        selectedCategories: viewModel.selectedCategories
                    )
                    if !viewModel.selectedCategories.isEmpty {
                        Button {
                            withAnimation {
                                viewModel.clearCategories()
                            }
                        } label: {
                            Text("Clear")
                        }

                    }
                }
                List {
                    ForEach(viewModel.filteredSubstances) { sub in
                        SearchSubstanceRow(substance: sub, color: nil)
                    }
                    ForEach(viewModel.filteredCustomSubstances) { cust in
                        NavigationLink {
                            EditCustomSubstanceView(customSubstance: cust)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(cust.nameUnwrapped).font(.headline)
                                Spacer().frame(height: 5)
                                Chip(name: "custom")
                            }
                        }
                    }
                    if viewModel.filteredSubstances.isEmpty && viewModel.filteredCustomSubstances.isEmpty {
                        Text("No Results")
                            .foregroundColor(.secondary)
                    }
                    Button {
                        viewModel.isShowingAddCustomSubstance.toggle()
                    } label: {
                        Label("New Custom Substance", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                    }
                    .sheet(isPresented: $viewModel.isShowingAddCustomSubstance) {
                        AddCustomSubstanceView()
                    }
                }
                .listStyle(.plain)
                .optionalScrollDismissesKeyboard()
            }
            .onSameTabTap {
                viewModel.searchText = ""
                isSearchFocused = true
            }
        }
    }
}
