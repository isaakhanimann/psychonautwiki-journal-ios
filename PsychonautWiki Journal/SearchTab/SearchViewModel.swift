import Foundation
import Combine
import CoreData

class SearchViewModel: ObservableObject {
    var filteredSubstances: [Substance] {
        SubstanceRepo.shared.substances.filter { sub in
            sub.name.lowercased().hasPrefix(searchText.lowercased())
        }
    }
    @Published var searchText = ""
}
