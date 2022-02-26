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

    func getPsychoactiveClass(with name: String) -> PsychoactiveClass? {
        let lowerCaseName = name.lowercased()
        return psychoactiveClassesUnwrapped.first { pClass in
            pClass.nameUnwrapped.lowercased() == lowerCaseName
        }
    }
}
