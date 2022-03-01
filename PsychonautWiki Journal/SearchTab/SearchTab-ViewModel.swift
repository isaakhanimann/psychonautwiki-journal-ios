import Foundation
import Combine
import CoreData

extension SearchTab {
    enum GroupBy {
        case psychoactive, chemical
    }
    struct SubstanceSection: Identifiable, Comparable {
        static func < (lhs: SearchTab.SubstanceSection, rhs: SearchTab.SubstanceSection) -> Bool {
            lhs.sectionName < rhs.sectionName
        }
        // swiftlint:disable identifier_name
        var id: String {
            sectionName
        }
        let sectionName: String
        let substances: [Substance]
    }
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var sections: [SubstanceSection] = []
        @Published var searchText = "" {
            didSet {
                setupFetchRequestPredicateAndFetch()
            }
        }
        @Published var groupBy = GroupBy.psychoactive {
            didSet {
                setupFetchRequestPredicateAndFetch()
            }
        }

        private let substanceFetchController: NSFetchedResultsController<Substance>?

        init(isPreview: Bool = false) {
            sections = SearchTab.ViewModel.getSections(substances: PreviewHelper.shared.allSubstances)
            searchText = "LS"
            substanceFetchController = nil
        }

        override init() {
            let fetchRequest = Substance.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Substance.name, ascending: true) ]
            substanceFetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            substanceFetchController?.delegate = self
            do {
                try substanceFetchController?.performFetch()
                let substances = substanceFetchController?.fetchedObjects ?? []
                sections = SearchTab.ViewModel.getSections(substances: substances)
            } catch {
                NSLog("Error: could not fetch SubstancesFiles")
            }
        }

        private static func getSections(substances: [Substance]) -> [SubstanceSection] {
            var sections: [SubstanceSection] = []
            let groupedByClass = Dictionary(grouping: substances) { sub in
                sub.psychoactivesUnwrapped.first?.name ?? "Miscellaneous"
            }
            for (sectionName, subs) in groupedByClass {
                sections.append(SubstanceSection(sectionName: sectionName, substances: subs.sorted()))
            }
            return sections.sorted()
        }

        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let subs = controller.fetchedObjects as? [Substance] else {return}
            sections = SearchTab.ViewModel.getSections(substances: subs)
        }

        private func setupFetchRequestPredicateAndFetch() {
            if searchText == "" {
                substanceFetchController?.fetchRequest.predicate = nil
            } else {
                let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText as CVarArg)
                substanceFetchController?.fetchRequest.predicate = predicate
            }
            try? substanceFetchController?.performFetch()
            let substances = substanceFetchController?.fetchedObjects ?? []
            sections = SearchTab.ViewModel.getSections(substances: substances)

        }

    }
}
