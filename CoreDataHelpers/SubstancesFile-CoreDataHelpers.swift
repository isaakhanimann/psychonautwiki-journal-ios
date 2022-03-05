import Foundation

extension SubstancesFile {

    var creationDateUnwrapped: Date {
        creationDate ?? Date()
    }

    var psychoactiveClassesUnwrapped: [PsychoactiveClass] {
        (psychoactiveClasses?.allObjects as? [PsychoactiveClass] ?? []).sorted()
    }

    var chemicalClassesUnwrapped: [ChemicalClass] {
        (chemicalClasses?.allObjects as? [ChemicalClass] ?? []).sorted()
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
