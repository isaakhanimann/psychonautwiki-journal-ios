import Foundation
import CoreData

extension JournalScreen {
    @MainActor
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var experiences: [Experience] = []
        @Published var searchText = "" {
            didSet {
                setupFetchRequestPredicateAndFetch()
            }
        }
        @Published var isShowingAddIngestionSheet = false
        @Published var isTimeRelative = false
        @Published var isFavoriteFilterEnabled = false {
            didSet {
                setupFetchRequestPredicateAndFetch()
            }
        }
        private let experienceFetchController: NSFetchedResultsController<Experience>!

        override init() {
            let fetchRequest = Experience.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false) ]
            experienceFetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            experienceFetchController.delegate = self
            do {
                try experienceFetchController.performFetch()
                self.experiences = experienceFetchController?.fetchedObjects ?? []
            } catch {
                NSLog("Error: could not fetch Experiences")
            }
        }

        private func setupFetchRequestPredicateAndFetch() {
            let predicateFavorite = NSPredicate(
                format: "isFavorite == %@",
                NSNumber(value: isFavoriteFilterEnabled)
            )
            if searchText == "" {
                experienceFetchController?.fetchRequest.predicate = predicateFavorite
            } else {
                let predicateTitle = NSPredicate(
                    format: "title CONTAINS[cd] %@",
                    searchText as CVarArg
                )
                let predicateSubstance = NSPredicate(
                    format: "%K.%K CONTAINS[cd] %@",
                    #keyPath(Experience.ingestions),
                    #keyPath(Ingestion.substanceName),
                    searchText as CVarArg
                )
                let titleOrSubstancePredicate = NSCompoundPredicate(
                    orPredicateWithSubpredicates: [predicateTitle, predicateSubstance]
                )
                let completePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFavorite, titleOrSubstancePredicate])
                experienceFetchController?.fetchRequest.predicate = completePredicate
            }
            try? experienceFetchController?.performFetch()
            self.experiences = experienceFetchController?.fetchedObjects ?? []
        }

        nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let exps = controller.fetchedObjects as? [Experience] else {return}
            Task {
                await MainActor.run {
                    self.experiences = exps
                }
            }
        }

        func delete(experience: Experience) {
            let viewContext = PersistenceController.shared.viewContext
            viewContext.delete(experience)
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }
}
