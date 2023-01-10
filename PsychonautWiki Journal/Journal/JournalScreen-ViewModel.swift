import Foundation
import CoreData

extension JournalScreen {
    @MainActor
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var currentExperiences: [Experience] = []
        @Published var previousExperiences: [Experience] = []
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
        private let experienceFetchController: NSFetchedResultsController<Experience>?

        override init() {
            let fetchRequest = Experience.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false) ]
            experienceFetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            experienceFetchController?.delegate = self
            do {
                try experienceFetchController?.performFetch()
                let experiences = experienceFetchController?.fetchedObjects ?? []
                splitExperiencesInCurrentAndPrevious(experiences: experiences)
            } catch {
                NSLog("Error: could not fetch Experiences")
            }
        }

        private func splitExperiencesInCurrentAndPrevious(experiences: [Experience]) {
            self.currentExperiences = experiences.prefix(while: { exp in
                exp.isCurrent
            })
            self.previousExperiences = experiences.suffix(experiences.count-currentExperiences.count)
        }

        private func setupFetchRequestPredicateAndFetch() {
            experienceFetchController?.fetchRequest.predicate = getPredicate()
            try? experienceFetchController?.performFetch()
            let experiences = experienceFetchController?.fetchedObjects ?? []
            splitExperiencesInCurrentAndPrevious(experiences: experiences)
        }

        private func getPredicate() -> NSPredicate? {
            let predicateFavorite = NSPredicate(
                format: "isFavorite == %@",
                NSNumber(value: true)
            )
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
            if isFavoriteFilterEnabled {
                if searchText.isEmpty {
                    return predicateFavorite
                } else {
                    let titleOrSubstancePredicate = NSCompoundPredicate(
                        orPredicateWithSubpredicates: [predicateTitle, predicateSubstance]
                    )
                    return NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFavorite, titleOrSubstancePredicate])
                }
            } else {
                if searchText.isEmpty {
                    return nil
                } else {
                    return NSCompoundPredicate(
                        orPredicateWithSubpredicates: [predicateTitle, predicateSubstance]
                    )
                }
            }
        }

        nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let exps = controller.fetchedObjects as? [Experience] else {return}
            Task {
                await MainActor.run {
                    splitExperiencesInCurrentAndPrevious(experiences: exps)
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
