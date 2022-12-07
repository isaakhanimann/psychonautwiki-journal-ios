import Foundation
import Combine
import CoreData

class SearchViewModel: ObservableObject {
    var filteredSubstances: [Substance] {
        if searchText.count < 3 {
            return getSortedPrefixResults()
        } else {
            let prefixResult = getSortedPrefixResults()
            if prefixResult.count < 3 {
                let containsResult = getSortedContainsResults()
                return (prefixResult + containsResult).uniqued { sub in
                    sub.name
                }
            } else {
                return prefixResult
            }

        }
    }
    @Published var searchText = ""

    private func getSortedPrefixResults() -> [Substance] {
        let lowerCaseSearchText = searchText.lowercased()
        let mainPrefixMatches =  SubstanceRepo.shared.substances.filter { sub in
            sub.name.lowercased().hasPrefix(lowerCaseSearchText)
        }
        if mainPrefixMatches.isEmpty {
            return SubstanceRepo.shared.substances.filter { sub in
                let names = sub.commonNames + [sub.name]
                return names.contains { name in
                    name.lowercased().hasPrefix(lowerCaseSearchText)
                }
            }
        } else {
            return mainPrefixMatches
        }
    }

    private func getSortedContainsResults() -> [Substance] {
        let lowerCaseSearchText = searchText.lowercased()
        let mainPrefixMatches =  SubstanceRepo.shared.substances.filter { sub in
            sub.name.lowercased().contains(lowerCaseSearchText)
        }
        if mainPrefixMatches.isEmpty {
            return SubstanceRepo.shared.substances.filter { sub in
                let names = sub.commonNames + [sub.name]
                return names.contains { name in
                    name.lowercased().contains(lowerCaseSearchText)
                }
            }
        } else {
            return mainPrefixMatches
        }
    }
}
