import Foundation
import Combine
import CoreData

enum GroupBy {
    case psychoactive, chemical
}
struct SubstanceSection: Identifiable, Comparable {
    static func < (lhs: SubstanceSection, rhs: SubstanceSection) -> Bool {
        lhs.sectionName < rhs.sectionName
    }
    // swiftlint:disable identifier_name
    var id: String {
        sectionName
    }
    let sectionName: String
    let substances: [Substance]
}
class SectionedSubstancesViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
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
    private var substances: [Substance] = []
    private let substanceFetchController: NSFetchedResultsController<Substance>?

    init(isPreview: Bool) {
        substances = PreviewHelper.shared.allSubstances
        groupBy = .psychoactive
        sections = SectionedSubstancesViewModel.getSections(substances: substances, groupBy: .psychoactive)
        searchText = "LS"
        substanceFetchController = nil
    }

    override init() {
        let substanceFetchRequest = Substance.fetchRequest()
        substanceFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Substance.name, ascending: true) ]
        substanceFetchController = NSFetchedResultsController(
            fetchRequest: substanceFetchRequest,
            managedObjectContext: PersistenceController.shared.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        super.init()
        substanceFetchController?.delegate = self
        groupBy = .psychoactive
        do {
            try substanceFetchController?.performFetch()
            substances = substanceFetchController?.fetchedObjects ?? []
            sections = SectionedSubstancesViewModel.getSections(substances: substances, groupBy: .psychoactive)
        } catch {
            NSLog("Error: could not fetch SubstancesFiles")
        }
    }

    private static func getSections(substances: [Substance], groupBy: GroupBy) -> [SubstanceSection] {
        var sections: [SubstanceSection] = []
        var groupedByClass: [String: [Substance]]
        switch groupBy {
        case .psychoactive:
            groupedByClass = Dictionary(grouping: substances) { sub in
                sub.psychoactivesUnwrapped.first?.name ?? "Miscellaneous"
            }
        case .chemical:
            groupedByClass = Dictionary(grouping: substances) { sub in
                sub.chemicalsUnwrapped.first?.name ?? "Miscellaneous"
            }
        }
        for (sectionName, subs) in groupedByClass {
            sections.append(SubstanceSection(sectionName: sectionName, substances: subs.sorted()))
        }
        return sections.sorted()
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let subs = controller.fetchedObjects as? [Substance] else {return}
        sections = SectionedSubstancesViewModel.getSections(substances: subs, groupBy: groupBy)
    }

    private func setupFetchRequestPredicateAndFetch() {
        if searchText == "" {
            substanceFetchController?.fetchRequest.predicate = nil
        } else {
            let predicateSubstance = NSPredicate(format: "name CONTAINS[cd] %@", searchText as CVarArg)
            let predicateClass: NSPredicate
            switch groupBy {
            case .psychoactive:
                predicateClass = NSPredicate(format: "firstPsychoactiveName CONTAINS[cd] %@", searchText as CVarArg)
            case .chemical:
                predicateClass = NSPredicate(format: "firstChemicalName CONTAINS[cd] %@", searchText as CVarArg)
            }
            let compound = NSCompoundPredicate(orPredicateWithSubpredicates: [predicateSubstance, predicateClass])
            substanceFetchController?.fetchRequest.predicate = compound
        }
        try? substanceFetchController?.performFetch()
        substances = substanceFetchController?.fetchedObjects ?? []
        sections = SectionedSubstancesViewModel.getSections(substances: substances, groupBy: groupBy)
    }

}
