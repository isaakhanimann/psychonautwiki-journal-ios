import Foundation

extension SubstancesFile {

    var creationDateUnwrapped: Date {
        creationDate ?? Date()
    }

    var psychoactiveClassesUnwrapped: [PsychoactiveClass] {
        psychoactiveClasses?.allObjects as? [PsychoactiveClass] ?? []
    }

    var psychoactiveClassesSorted: [PsychoactiveClass] {
        psychoactiveClassesUnwrapped.sorted { pClass1, pClass2 in
            pClass1.nameUnwrapped < pClass2.nameUnwrapped
        }
    }

    var chemicalClassesUnwrapped: [ChemicalClass] {
        chemicalClasses?.allObjects as? [ChemicalClass] ?? []
    }

    var chemicalClassesSorted: [ChemicalClass] {
        chemicalClassesUnwrapped.sorted { cClass1, cClass2 in
            cClass1.nameUnwrapped < cClass2.nameUnwrapped
        }
    }

    static let okInteractionNames: Set = [
        "alcohol",
        "antihistamine",
        "diphenhydramine",
        "grapefruit",
        "hormonal birth control",
        "snris",
        "serotonin",
        "selective serotonin reuptake inhibitor",
        "tricyclic antidepressants"
    ]
}
