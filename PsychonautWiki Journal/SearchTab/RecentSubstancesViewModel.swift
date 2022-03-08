import Foundation
import CoreData

class RecentSubstancesViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var recentSubstances: [Substance] = []
    private var ingestions: [Ingestion] = []
    private let recentIngestionFetchController: NSFetchedResultsController<Ingestion>?

    init(isPreview: Bool) {
        self.recentSubstances = Array(PreviewHelper.shared.allSubstances.prefix(upTo: 10))
        self.recentIngestionFetchController = nil
    }

    override init() {
        let ingestionFetchRequest = Ingestion.fetchRequest()
        ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
        ingestionFetchRequest.fetchLimit = 10
        recentIngestionFetchController = NSFetchedResultsController(
            fetchRequest: ingestionFetchRequest,
            managedObjectContext: PersistenceController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        recentIngestionFetchController?.delegate = self
        do {
            try recentIngestionFetchController?.performFetch()
            self.ingestions = recentIngestionFetchController?.fetchedObjects ?? []
            setDistinctSubstances()
        } catch {
            NSLog("Error: could not fetch SubstancesFiles")
        }
    }

    private func setDistinctSubstances() {
        let nonNilSubstances = ingestions.compactMap { ing in
            ing.substance
        }
        self.recentSubstances = nonNilSubstances.uniqued()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let ings = controller.fetchedObjects as? [Ingestion] else {return}
        self.ingestions = ings
        setDistinctSubstances()
    }
}
