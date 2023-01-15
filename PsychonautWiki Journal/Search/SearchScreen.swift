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

    @StateObject var viewModel = SearchViewModel()

    var body: some View {
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
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search Substance")
        )
        .disableAutocorrection(true)
        .navigationTitle("Substances")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu(content: {
                    ForEach(viewModel.allCategories, id: \.self) { cat in
                        Button {
                            withAnimation {
                                viewModel.toggleCategory(category: cat)
                            }
                        } label: {
                            if viewModel.selectedCategories.contains(cat) {
                                Label(cat, systemImage: "checkmark")
                            } else {
                                Text(cat)
                            }
                        }
                    }
                }, label: {
                    Label("Filter", systemImage: viewModel.selectedCategories.isEmpty ? "line.3.horizontal.decrease.circle": "line.3.horizontal.decrease.circle.fill")
                })
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
        }
    }
}
