import Foundation
import CoreData

extension SettingsTab {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var isFetching = false
        @Published var isResetting = false
        @Published var substancesFile: SubstancesFile?
        var toastViewModel: ToastViewModel?

        private let fetchController: NSFetchedResultsController<SubstancesFile>!

        override init() {
            let fetchRequest = SubstancesFile.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
            fetchRequest.fetchLimit = 1
            fetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            fetchController.delegate = self
            do {
                try fetchController.performFetch()
                self.substancesFile = (fetchController?.fetchedObjects ?? []).first
            } catch {
                NSLog("Error: could not fetch Substance files")
            }
        }

        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let files = controller.fetchedObjects as? [SubstancesFile] else {return}
            self.substancesFile = files.first
        }

        @MainActor func fetchNewSubstances() async {
            isFetching = true
            do {
                let data = try await getPsychonautWikiData()
                try await PersistenceController.shared.decodeAndSaveFile(from: data)
            } catch {
                toastViewModel?.showErrorToast(message: "Try Again Later")
            }
            isFetching = false
        }

        @MainActor func resetSubstances() async {
            isResetting = true
            await PersistenceController.shared.resetAllSubstancesToInitialAndSave()
            isResetting = false
        }
    }
}
