import Foundation
import CoreData

@MainActor
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
        substancesWithColor = ingestions.map({ ing in
            ing.substanceNameUnwrapped
        }).uniqued().compactMap({ substanceName in
            guard let substance = SubstanceRepo.shared.getSubstance(name: substanceName) else {return nil}
            return SubstanceWithColor(substance: substance, color: getColor(for: substanceName))
        })
    }

    nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task {
            await MainActor.run(body: {
                setSubstancesWithColor()
            })

        }
    }
}

struct SubstanceWithColor: Identifiable {
    var id: String {
        substance.name
    }
    let substance: Substance
    let color: SubstanceColor
}
