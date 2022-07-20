import Foundation
import Combine
import CoreData

class SectionedSubstancesViewModel: ObservableObject {
    var substances: [Substance] = []
    private var cancellable: AnyCancellable?
    private var isEyeOpen = false
    var searchText = ""

}
