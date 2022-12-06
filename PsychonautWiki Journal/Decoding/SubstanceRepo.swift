import Foundation
import CoreData

class SubstanceRepo {

    static let shared = SubstanceRepo()

    let substances: [Substance]
    let categories: [Category]
    private let substancesDict: [String: Substance]

    init() {
        let data = SubstanceRepo.getInitialData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        decoder.keyDecodingStrategy = .useDefaultKeys
        // swiftlint:disable force_try
        let file = try! decoder.decode(SubstanceFile.self, from: data)
        substances = file.substances
        categories = file.categories
        substancesDict = Dictionary(
            uniqueKeysWithValues: substances.map({ substance in
                (substance.name, substance)
            })
        )
    }

    func getSubstance(name: String) -> Substance? {
        substancesDict[name]
    }

    static private func getInitialData() -> Data {
        let fileName = "substances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }
        return data
    }
}
