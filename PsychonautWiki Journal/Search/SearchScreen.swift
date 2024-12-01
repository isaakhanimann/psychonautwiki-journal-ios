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
import AppIntents

struct SearchScreen: View {

    @FocusState var isSearchFocused: Bool
    @Binding var searchText: String
    @Binding var selectedCategories: [String]
    let clearCategories: () -> Void


    @State private var isShowingAddCustomSubstance = false


    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomSubstance.name, ascending: true)]
    ) private var customSubstances: FetchedResults<CustomSubstance>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) private var ingestions: FetchedResults<Ingestion>
    
    private static let custom = "custom"
    
    let allCategories = [custom] + SubstanceRepo.shared.categories.map { cat in
        cat.name
    }
    
    func toggleCategory(category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { cat in
                cat == category
            }
        } else {
            selectedCategories.append(category)
        }
    }
    
    var customFilteredWithCategories: [CustomSubstance] {
        if selectedCategories.isEmpty {
            return Array(customSubstances)
        } else if selectedCategories.contains(SearchScreen.custom) {
            return Array(customSubstances)
        } else {
            return []
        }
    }
    
    var customSubstancesFiltered: [CustomSubstance] {
        let lowerCaseSearchText = searchText.lowercased()
        if searchText.count < 3 {
            return customFilteredWithCategories.filter { cust in
                cust.nameUnwrapped.lowercased().hasPrefix(lowerCaseSearchText)
            }
        } else {
            return customFilteredWithCategories.filter { cust in
                cust.nameUnwrapped.lowercased().contains(lowerCaseSearchText)
            }
        }
    }
    
    var substancesFilteredAndSorted: [Substance] {
        let substancesFilteredWithCategoriesOnly = SubstanceRepo.shared.substances.filter { sub in
            selectedCategories.allSatisfy { selected in
                sub.categories.contains(selected)
            }
        }
        let substanceNamesInOrder = ingestions.prefix(500).map { ing in
            ing.substanceNameUnwrapped
        }.uniqued()
        return SearchLogic.getFilteredSubstancesSorted(
            substances: substancesFilteredWithCategoriesOnly,
            searchText: searchText,
            namesToSortBy: substanceNamesInOrder
        )
    }

    @AppStorage("isSearchSubstanceSiriTipVisible") private var isSiriTipVisible = true

    var body: some View {
        VStack(spacing: 0) {
            SubstanceSearchBarWithFilter(
                text: $searchText,
                isFocused: $isSearchFocused,
                allCategories: allCategories,
                toggleCategory: { cat in
                    toggleCategory(category: cat)
                },
                selectedCategories: selectedCategories,
                clearCategories: {
                    clearCategories()
                }
            )

            SiriTipView(intent: SearchSubstancesIntent(), isVisible: $isSiriTipVisible)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            List {
                ForEach(substancesFilteredAndSorted) { sub in
                    SearchSubstanceRow(substance: sub)
                }
                ForEach(customSubstancesFiltered) { cust in
                    NavigationLink(value: GlobalNavigationDestination.editCustomSubstance(customSubstance: cust)) {
                        VStack(alignment: .leading) {
                            Text(cust.nameUnwrapped).font(.headline)
                            Spacer().frame(height: 5)
                            Chip(name: "custom")
                        }
                    }
                }
                if substancesFilteredAndSorted.isEmpty && customSubstancesFiltered.isEmpty {
                    Text("No Results")
                        .foregroundColor(.secondary)
                }
                Button {
                    isShowingAddCustomSubstance.toggle()
                } label: {
                    Label("New Custom Substance", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }
                .sheet(isPresented: $isShowingAddCustomSubstance) {
                    AddCustomSubstanceView(searchText: searchText, onAdded: { _ in})
                }
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.interactively)
        }
    }
}
