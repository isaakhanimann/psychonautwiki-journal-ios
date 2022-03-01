import Foundation
import Combine
import CoreData

extension SearchTab {
    enum GroupBy {
        case psychoactive, chemical
    }
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var sortedSubstances: [Substance] = []
        @Published var searchText = "" {
            didSet {
              setupFetchRequestPredicateAndFetch()
            }
          }
        @Published var groupBy = GroupBy.psychoactive

        private let substanceFetchController: NSFetchedResultsController<Substance>?

        init(isPreview: Bool = false) {
            sortedSubstances = PreviewHelper.shared.allSubstances
            searchText = "Hello for Preview"
            substanceFetchController = nil
        }

        override init() {
            let fetchRequest = Substance.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Substance.name, ascending: true) ]
            substanceFetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            substanceFetchController?.delegate = self
            do {
                try substanceFetchController?.performFetch()
                sortedSubstances = substanceFetchController?.fetchedObjects ?? []
            } catch {
                NSLog("Error: could not fetch SubstancesFiles")
            }
        }

        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let subs = controller.fetchedObjects as? [Substance] else {return}
            self.sortedSubstances = subs
        }

        private func setupFetchRequestPredicateAndFetch() {
          if searchText == "" {
              substanceFetchController?.fetchRequest.predicate = nil
          } else {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText as CVarArg)
              substanceFetchController?.fetchRequest.predicate = predicate
          }
          try? substanceFetchController?.performFetch()
          sortedSubstances = substanceFetchController?.fetchedObjects ?? []
        }

    }
}
