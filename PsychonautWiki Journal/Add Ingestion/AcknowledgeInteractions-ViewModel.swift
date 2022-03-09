import Foundation
import Algorithms

extension AcknowledgeInteractionsView {

    class ViewModel: ObservableObject {

        var hasInteractions: Bool {
            hasDangerousInteractions || hasUnsafeInteractions || hasUncertainInteractions
        }
        var hasDangerousInteractions: Bool {
            !dangerousIngestions.isEmpty
        }
        var hasUnsafeInteractions: Bool {
            !unsafeIngestions.isEmpty
        }
        var hasUncertainInteractions: Bool {
            !uncertainIngestions.isEmpty
        }
        @Published var dangerousIngestions = [Ingestion]()
        @Published var unsafeIngestions = [Ingestion]()
        @Published var uncertainIngestions = [Ingestion]()
        @Published var isShowingAlert = false
        @Published var isShowingNext = false

        func checkInteractionsWith(substance: Substance) {
            let recentIngestions = getRecentIngestions()
            setInteractionIngestions(from: recentIngestions, substance: substance)
        }

        func getRecentIngestions() -> [Ingestion] {
            let fetchRequest = Ingestion.fetchRequest()
            let twoDaysAgo = Date().addingTimeInterval(-2*24*60*60)
            fetchRequest.predicate = NSPredicate(format: "time > %@", twoDaysAgo as NSDate)
            return (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
        }

        func setInteractionIngestions(from ingestions: [Ingestion], substance: Substance) {
            let chunkedIngestions = ingestions.chunked { ing in
                ing.getInteraction(with: substance)
            }
            for chunk in chunkedIngestions {
                let type = chunk.0
                let sameTypeIngs = getDistinctSubstanceLatestIngestion(from: chunk.1)
                switch type {
                case .none:
                    break
                case .uncertain:
                    self.uncertainIngestions = sameTypeIngs
                case .unsafe:
                    self.unsafeIngestions = sameTypeIngs
                case .dangerous:
                    self.dangerousIngestions = sameTypeIngs
                }
            }
        }

        func getDistinctSubstanceLatestIngestion(from ingestions: Array<Ingestion>.SubSequence) -> [Ingestion] {
            let sortedIngestions  = ingestions.sorted().reversed()
            var distinctIngestions = [Ingestion]()
            var seenSubstanceNames: Set<String> = []
            for ingestion in sortedIngestions {
                let name = ingestion.substanceNameUnwrapped
                if !seenSubstanceNames.contains(name) {
                    distinctIngestions.append(ingestion)
                    seenSubstanceNames.insert(name)
                }
            }
            return distinctIngestions
        }

        func pressNext() {
            if hasInteractions {
                isShowingAlert = true
            } else {
                isShowingNext = true
            }
        }
    }
}
