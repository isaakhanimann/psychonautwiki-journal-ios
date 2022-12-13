import Foundation
import Algorithms

extension AcknowledgeInteractionsView {

    class ViewModel: ObservableObject, InteractionAlertable {

        @Published var dangerousIngestions = [Ingestion]()
        @Published var unsafeIngestions = [Ingestion]()
        @Published var uncertainIngestions = [Ingestion]()
        @Published var isShowingAlert = false
        @Published var isShowingNext = false

        func hideAlert() {
            isShowingAlert.toggle()
        }

        func showNext() {
            isShowingNext.toggle()
        }

        func checkInteractionsWith(substance: Substance) {
            let recentIngestions = PersistenceController.shared.getRecentIngestions()
            setInteractionIngestions(from: recentIngestions, substance: substance)
        }

        func setInteractionIngestions(from ingestions: [Ingestion], substance: Substance) {
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
            if !dangerousIngestions.isEmpty || !unsafeIngestions.isEmpty || !uncertainIngestions.isEmpty {
                isShowingAlert = true
            } else {
                isShowingNext = true
            }
        }
    }
}
