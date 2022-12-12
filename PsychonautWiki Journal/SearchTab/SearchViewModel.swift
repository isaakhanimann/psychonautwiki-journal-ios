import Foundation
import Combine
import CoreData

class SearchViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

    var filteredSubstances: [Substance] = SubstanceRepo.shared.substances

    @Published var searchText = "" {
        didSet {
            setFilteredSubstances()
        }
    }

    private func setFilteredSubstances() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.searchText.count < 3 {
                let prefixResult = self.getSortedPrefixResults()
                DispatchQueue.main.async {
                    self.filteredSubstances =  prefixResult
                }
            } else {
                let prefixResult = self.getSortedPrefixResults()
                if prefixResult.count < 3 {
                    let containsResult = self.getSortedContainsResults()
                    let combinedResult =  (prefixResult + containsResult).uniqued { sub in
                        sub.name
                    }
                    DispatchQueue.main.async {
                        self.filteredSubstances =  combinedResult
                    }

                } else {
                    DispatchQueue.main.async {
                        self.filteredSubstances =  prefixResult
                    }
                }
            }
        }
    }


    @Published var selectedCategories: [String] = [] {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                self.substancesFilteredWithCategoriesOnly = SubstanceRepo.shared.substances.filter { sub in
                    self.selectedCategories.allSatisfy { selected in
                        sub.categories.contains(selected)
                    }
                }
            }
            setFilteredSubstances()
        }
    }

    private var substancesFilteredWithCategoriesOnly: [Substance] = SubstanceRepo.shared.substances

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

    private func getSortedPrefixResults() -> [Substance] {
        let lowerCaseSearchText = searchText.lowercased()
        let mainPrefixMatches =  substancesFilteredWithCategoriesOnly.filter { sub in
            sub.name.lowercased().hasPrefix(lowerCaseSearchText)
        }
        if mainPrefixMatches.isEmpty {
            return substancesFilteredWithCategoriesOnly.filter { sub in
                let names = sub.commonNames + [sub.name]
                return names.contains { name in
                    name.lowercased().hasPrefix(lowerCaseSearchText)
                }
            }
        } else {
            return mainPrefixMatches
        }
    }

    private func getSortedContainsResults() -> [Substance] {
        let lowerCaseSearchText = searchText.lowercased()
        let mainPrefixMatches =  substancesFilteredWithCategoriesOnly.filter { sub in
            sub.name.lowercased().contains(lowerCaseSearchText)
        }
        if mainPrefixMatches.isEmpty {
            return substancesFilteredWithCategoriesOnly.filter { sub in
                let names = sub.commonNames + [sub.name]
                return names.contains { name in
                    name.lowercased().contains(lowerCaseSearchText)
                }
            }
        } else {
            return mainPrefixMatches
        }
    }

    @Published private var customSubstances: [CustomSubstance] = []
    private let fetchController: NSFetchedResultsController<CustomSubstance>!

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
        fetchController.delegate = self
        do {
            try fetchController.performFetch()
            self.customSubstances = fetchController?.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch CustomSubstances")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let customs = controller.fetchedObjects as? [CustomSubstance] else {return}
        self.customSubstances = customs
    }
}
