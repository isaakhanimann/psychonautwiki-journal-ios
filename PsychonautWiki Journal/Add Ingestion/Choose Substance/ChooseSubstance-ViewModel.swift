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

import CoreData
import Foundation

// swiftlint:disable function_body_length
extension ChooseSubstanceScreen {
    @MainActor
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var searchText = ""
        @Published var isShowingOpenEyeToast = false
        @Published var filteredSuggestions: [any SuggestionProtocol] = []
        @Published var filteredSubstances: [Substance] = []
        @Published var filteredCustomUnits: [CustomUnit] = []
        @Published var filteredCustomSubstances: [CustomSubstanceModel] = []
        @Published var customSubstanceModels: [CustomSubstanceModel]
        @Published var isEyeOpen = false

        private let allPossibleSuggestions: [any SuggestionProtocol]
        private let fetchController: NSFetchedResultsController<CustomSubstance>?

        private static func getSortedIngestions() -> [Ingestion] {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Ingestion.creationDate, ascending: false)]
            ingestionFetchRequest.fetchLimit = 1000
            return (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
        }

        private static func getCustomUnits() -> [CustomUnit] {
            let unitsFetchRequest = CustomUnit.fetchRequest()
            unitsFetchRequest.predicate = NSPredicate(format: "isArchived == %@", NSNumber(value: false))
            return (try? PersistenceController.shared.viewContext.fetch(unitsFetchRequest)) ?? []
        }

        override init() {
            isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey2)
            let customUnits = Self.getCustomUnits()
            allPossibleSuggestions = getSuggestions(sortedIngestions: Self.getSortedIngestions(), customUnits: customUnits)
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
            customSubstanceModels = customSubstances.map { cust in
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
            $filteredSubstances.combineLatest($filteredCustomSubstances, $searchText) { [self] filteredSubstances, filteredCustom, searchTextValue in
                let filteredSuggestions = allPossibleSuggestions.filter { suggestion in
                    let substanceNames = filteredSubstances.map(\.name) + filteredCustom.map(\.name)
                    return suggestion.isInResult(searchText: searchTextValue, substanceNames: substanceNames)
                }
                return filteredSuggestions
            }.assign(to: &$filteredSuggestions)
            $searchText.combineLatest($filteredSubstances) { searchText, filteredSubstances in
                customUnits.filter { customUnit in
                    filteredSubstances.contains { substance in
                        customUnit.substanceNameUnwrapped == substance.name
                    } || customUnit.nameUnwrapped.lowercased().contains(searchText.lowercased())
                    || customUnit.substanceNameUnwrapped.lowercased().contains(searchText.lowercased())
                    || customUnit.unitUnwrapped.lowercased().contains(searchText.lowercased())
                    || customUnit.noteUnwrapped.lowercased().contains(searchText.lowercased())
                }
            }.assign(to: &$filteredCustomUnits)
        }

        private func openEyeAndAnimate() {
            isEyeOpen = true
            UserDefaults.standard.set(true, forKey: PersistenceController.isEyeOpenKey2)
            isShowingOpenEyeToast = true
        }

        public nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            Task {
                await MainActor.run(body: {
                    guard let custs = controller.fetchedObjects as? [CustomSubstance] else { return }
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
// swiftlint:enable function_body_length
