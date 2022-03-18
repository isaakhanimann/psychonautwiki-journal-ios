import Foundation

extension SubstancesFile {

    var psychoactiveClassesUnwrapped: [PsychoactiveClass] {
        (psychoactiveClasses?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    var chemicalClassesUnwrapped: [ChemicalClass] {
        (chemicalClasses?.allObjects as? [ChemicalClass] ?? []).sorted()
    }
}
