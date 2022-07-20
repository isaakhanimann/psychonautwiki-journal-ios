import Foundation
import CoreData

class RecentSubstancesViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var recentSubstanceNames: [String] = []
    private let fetchController: NSFetchedResultsController<Ingestion>?

    override init() {
        let request = Ingestion.fetchRequest()
        request.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
        fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchController?.delegate = self
        try? fetchController?.performFetch()
        let ingestions = fetchController?.fetchedObjects ?? []
        recentSubstanceNames = ingestions.compactMap({ ing in
            ing.substanceName
        }).uniqued()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let ingestions = fetchController?.fetchedObjects ?? []
        recentSubstanceNames = ingestions.compactMap({ ing in
            ing.substanceName
        }).uniqued()
    }
}
