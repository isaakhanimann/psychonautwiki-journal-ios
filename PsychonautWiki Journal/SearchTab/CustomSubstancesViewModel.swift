import Foundation
import CoreData

class CustomSubstancesViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var customSubstances: [CustomSubstance] = []
    private let fetchController: NSFetchedResultsController<CustomSubstance>!

    init(isPreview: Bool) {
        fetchController = nil
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
