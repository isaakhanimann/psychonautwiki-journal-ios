import Foundation
import CoreData

extension ExperiencesTab {
    struct ExperienceSection: Identifiable, Comparable {
        static func < (lhs: ExperienceSection, rhs: ExperienceSection) -> Bool {
            lhs.year > rhs.year
        }
        // swiftlint:disable identifier_name
        var id: Int {
            year
        }
        let year: Int
        let experiences: [Experience]
    }
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var experiences: [Experience] = []
        @Published var searchText = "" {
            didSet {
                setupFetchRequestPredicateAndFetch()
            }
        }
        private let experienceFetchController: NSFetchedResultsController<Experience>!

        override init() {
            let fetchRequest = Experience.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
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
            if searchText == "" {
                experienceFetchController?.fetchRequest.predicate = nil
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
                let predicateCompound = NSCompoundPredicate(
                    orPredicateWithSubpredicates: [predicateTitle, predicateSubstance]
                )
                experienceFetchController?.fetchRequest.predicate = predicateCompound
            }
            try? experienceFetchController?.performFetch()
            self.experiences = experienceFetchController?.fetchedObjects ?? []
        }

        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let exps = controller.fetchedObjects as? [Experience] else {return}
            self.experiences = exps
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
