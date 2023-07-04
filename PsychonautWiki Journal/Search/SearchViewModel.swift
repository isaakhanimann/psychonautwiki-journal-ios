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
import Combine
import CoreData

@MainActor
class SearchViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

    @Published var filteredSubstances: [Substance] = SubstanceRepo.shared.substances
    @Published var searchText = ""
    @Published var selectedCategories: [String] = []
    @Published var isShowingAddCustomSubstance = false


    static let custom = "custom"

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

    func clearCategories() {
        selectedCategories.removeAll()
    }

    @Published private var customSubstances: [CustomSubstance] = []
    private let fetchController: NSFetchedResultsController<CustomSubstance>?

    var customFilteredWithCategories: [CustomSubstance] {
        if selectedCategories.isEmpty {
            return customSubstances
        } else if selectedCategories.contains(SearchViewModel.custom) {
            return customSubstances
        } else {
            return []
        }
    }

    var filteredCustomSubstances: [CustomSubstance] {
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

    override init() {
        let fetchRequest = CustomSubstance.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \CustomSubstance.name, ascending: true) ]
        fetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistenceController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchController?.delegate = self
        do {
            try fetchController?.performFetch()
            self.customSubstances = fetchController?.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch CustomSubstances")
        }
        $searchText
            .combineLatest($selectedCategories) { search, cats in
                let substancesFilteredWithCategoriesOnly = SubstanceRepo.shared.substances.filter { sub in
                    cats.allSatisfy { selected in
                        sub.categories.contains(selected)
                    }
                }
                return SearchLogic.getFilteredSubstancesSorted(substances: substancesFilteredWithCategoriesOnly, searchText: search)
            }.assign(to: &$filteredSubstances)
    }

    nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let customs = controller.fetchedObjects as? [CustomSubstance] else {return}
        Task {
            await MainActor.run {
                self.customSubstances = customs
            }
        }
    }
}
