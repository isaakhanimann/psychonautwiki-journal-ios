//
//  ChooseSubstance-ViewModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 14.12.22.
//

import Foundation

extension ChooseSubstanceScreen {
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var searchText = ""
        @Published var filteredSuggestions: [Suggestion] =  []
        @Published var filteredSubstances: [Substance] = []
        @Published var filteredCustomSubstances: [CustomSubstanceModel] = []

        private let allPossibleSuggestions: [Suggestion]
        private let customSubstanceModels: [CustomSubstanceModel]

        init() {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            ingestionFetchRequest.fetchLimit = 100
            let sortedIngestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
            self.allPossibleSuggestions = SuggestionsCreator(sortedIngestions: sortedIngestions).suggestions
            let customFetchRequest = CustomSubstance.fetchRequest()
            let customSubstances = (try? PersistenceController.shared.viewContext.fetch(customFetchRequest)) ?? []
            self.customSubstanceModels = customSubstances.map { cust in
                CustomSubstanceModel(name: cust.nameUnwrapped, units: cust.unitsUnwrapped)
            }
            $searchText
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.global(qos: .userInitiated)) // debounce because if we type extremely fast it crashes
                .map { search in
                    let allSubstances = SubstanceRepo.shared.substances
                    return SearchViewModel.getFilteredSubstancesSorted(substances: allSubstances, searchText: search)
                }.receive(on: DispatchQueue.main).assign(to: &$filteredSubstances)
            $searchText
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.global(qos: .userInitiated)) // debounce because if we type extremely fast it crashes
                .map { search in
                    let searchLowerCased = search.lowercased()
                    return self.customSubstanceModels.filter { custModel in
                        custModel.name.lowercased().contains(searchLowerCased)
                    }
                }.receive(on: DispatchQueue.main).assign(to: &$filteredCustomSubstances)
            $filteredSubstances.combineLatest($filteredCustomSubstances) { filteredSubstances, filteredCustom in
                self.allPossibleSuggestions.filter { suggestion in
                    filteredSubstances.contains { substance in
                        substance.name == suggestion.substanceName
                    } || filteredCustom.contains { custom in
                        custom.name == suggestion.substanceName
                    }
                }
            }.assign(to: &$filteredSuggestions)
        }
    }
}

