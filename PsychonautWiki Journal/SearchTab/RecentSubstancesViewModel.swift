import Foundation
import CoreData

class RecentSubstancesViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var substancesWithColor: [SubstanceWithColor] = []
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
        setSubstancesWithColor()
    }

    private func setSubstancesWithColor() {
        let ingestions = fetchController?.fetchedObjects ?? []
        substancesWithColor = ingestions.uniqued(on: { ing in
            ing.substanceNameUnwrapped
        }).compactMap({ ing in
            guard let substance = SubstanceRepo.shared.getSubstance(name: ing.substanceNameUnwrapped) else {return nil}
            return SubstanceWithColor(substance: substance, color: ing.substanceColor)
        })
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setSubstancesWithColor()
    }
}

struct SubstanceWithColor: Identifiable {
    // swiftlint:disable identifier_name
    var id: String {
        substance.name
    }
    let substance: Substance
    let color: SubstanceColor
}
