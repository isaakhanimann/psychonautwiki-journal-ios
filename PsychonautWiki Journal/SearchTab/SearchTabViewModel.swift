import Foundation
import Combine
import CoreData

class SearchTabViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var sortedSubstances: [Substance] = []
    @Published var searchText = ""

    private let substanceFetchController: NSFetchedResultsController<Substance>

    override init() {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Substance.name, ascending: true) ]
        substanceFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistenceController.shared.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        super.init()
        substanceFetchController.delegate = self
        do {
            try substanceFetchController.performFetch()
            sortedSubstances = substanceFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch SubstancesFiles")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let subs = controller.fetchedObjects as? [Substance] else {return}
        self.sortedSubstances = subs
    }

}
