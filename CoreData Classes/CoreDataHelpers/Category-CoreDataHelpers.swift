import Foundation
import CoreData

extension Category {

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var substancesUnwrapped: [Substance] {
        substances?.allObjects as? [Substance] ?? []
    }

    var sortedSubstancesUnwrapped: [Substance] {
        substancesUnwrapped.sorted { (substance1, substance2) -> Bool in
            substance1.nameUnwrapped < substance2.nameUnwrapped
        }
    }

    var enabledSubstancesUnwrapped: [Substance] {
        substancesUnwrapped.filter { substance in
            substance.isEnabled
        }
    }

    var sortedEnabledSubstancesUnwrapped: [Substance] {
        enabledSubstancesUnwrapped.sorted { (substance1, substance2) -> Bool in
            substance1.nameUnwrapped < substance2.nameUnwrapped
        }
    }

    func getSubstance(with name: String) -> Substance? {
        substancesUnwrapped.first { substance in
            substance.nameUnwrapped == name
        }
    }
}
