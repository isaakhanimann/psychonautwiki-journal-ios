import Foundation
import Combine
import CoreData

class SubstanceFilePublisher: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    var file = CurrentValueSubject<SubstancesFile?, Never>(nil)
    private let fileFetchController: NSFetchedResultsController<SubstancesFile>

    static let shared: SubstanceFilePublisher = SubstanceFilePublisher()

    private override init() {
        let fetchRequest = SubstancesFile.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
        fileFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistenceController.shared.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        super.init()
        fileFetchController.delegate = self
        do {
            try fileFetchController.performFetch()
            file.value = fileFetchController.fetchedObjects?.first
        } catch {
            NSLog("Error: could not fetch SubstancesFiles")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let files = controller.fetchedObjects as? [SubstancesFile] else {return}
        self.file.value = files.first
    }
}
