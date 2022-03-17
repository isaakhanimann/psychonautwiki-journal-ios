import Foundation
import CoreData

class PresetsViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var presets: [Preset] = []
    private let fetchController: NSFetchedResultsController<Preset>!

    init(isPreview: Bool) {
        fetchController = nil
    }

    override init() {
        let fetchRequest = Preset.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Preset.name, ascending: true) ]
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
            self.presets = fetchController?.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch Presets")
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let pres = controller.fetchedObjects as? [Preset] else {return}
        self.presets = pres
    }
}
