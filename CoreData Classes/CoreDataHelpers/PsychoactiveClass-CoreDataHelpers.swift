import Foundation

extension PsychoactiveClass {
    var nameUnwrapped: String {
        name ?? "Miscellaneous"
    }

    var substancesUnwrapped: [Substance] {
        substances?.allObjects as? [Substance] ?? []
    }

    var sortedSubstancesUnwrapped: [Substance] {
        substancesUnwrapped.sorted { (substance1, substance2) -> Bool in
            substance1.nameUnwrapped < substance2.nameUnwrapped
        }
    }

}
