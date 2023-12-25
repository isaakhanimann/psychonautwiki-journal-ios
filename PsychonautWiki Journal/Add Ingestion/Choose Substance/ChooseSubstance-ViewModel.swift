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

import Foundation
import CoreData

extension ChooseSubstanceScreen {
    @MainActor
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        
        @Published var searchText = ""
        @Published var isShowingOpenEyeToast = false
        @Published var filteredSuggestions: [Suggestion] =  []
        @Published var filteredSubstances: [Substance] = []
        @Published var filteredCustomSubstances: [CustomSubstanceModel] = []
        @Published var customSubstanceModels: [CustomSubstanceModel]
        @Published var isEyeOpen = false

        private let allPossibleSuggestions: [Suggestion]
        private let fetchController: NSFetchedResultsController<CustomSubstance>?

        private static func getSortedIngestions() -> [Ingestion] {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            ingestionFetchRequest.fetchLimit = 300
            return (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
        }

        private static func getCustomUnits() -> [CustomUnit] {
            let unitsFetchRequest = CustomUnit.fetchRequest()
            unitsFetchRequest.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: true))
            return (try? PersistenceController.shared.viewContext.fetch(unitsFetchRequest)) ?? []
        }

        override init() {
            self.isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey2)
            self.allPossibleSuggestions = SuggestionsCreator(sortedIngestions: Self.getSortedIngestions(), customUnits: Self.getCustomUnits()).suggestions
            let request = CustomSubstance.fetchRequest()
            request.sortDescriptors = []
            fetchController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            try? fetchController?.performFetch()
            let customSubstances = fetchController?.fetchedObjects ?? []
            self.customSubstanceModels = customSubstances.map { cust in
                CustomSubstanceModel(
                    name: cust.nameUnwrapped,
                    description: cust.explanationUnwrapped,
                    units: cust.unitsUnwrapped
                )
            }
            super.init()
            fetchController?.delegate = self
            $searchText
                .combineLatest($isEyeOpen) { search, isEyeOpen in
                    let allSubstances = SubstanceRepo.shared.substances
                    let originalFiltered = SearchLogic.getFilteredSubstancesSorted(substances: allSubstances, searchText: search, namesToSortBy: [])
                    if isEyeOpen {
                        return originalFiltered
                    } else {
                        let isContainingIllegal = originalFiltered.contains { sub in
                            !namesOfLegalSubstances.contains(sub.name)
                        }
                        if search.count > 4 && isContainingIllegal {
                            self.openEyeAndAnimate()
                            return originalFiltered
                        } else {
                            return originalFiltered.filter { sub in
                                namesOfLegalSubstances.contains(sub.name)
                            }
                        }
                    }
                }.assign(to: &$filteredSubstances)
            $searchText
                .combineLatest($customSubstanceModels) { search, customs in
                    if search.isEmpty {
                        return customs
                    } else {
                        let searchLowerCased = search.lowercased()
                        return customs.filter { custModel in
                            custModel.name.lowercased().contains(searchLowerCased)
                        }
                    }
                }.assign(to: &$filteredCustomSubstances)
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

        private func openEyeAndAnimate() {
            isEyeOpen = true
            UserDefaults.standard.set(true, forKey: PersistenceController.isEyeOpenKey2)
            isShowingOpenEyeToast = true
        }

        nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            Task {
                await MainActor.run(body: {
                    guard let custs = controller.fetchedObjects as? [CustomSubstance] else {return}
                    self.customSubstanceModels = custs.map { cust in
                        CustomSubstanceModel(
                            name: cust.nameUnwrapped,
                            description: cust.explanationUnwrapped,
                            units: cust.unitsUnwrapped
                        )
                    }
                })
            }
        }
    }
}

