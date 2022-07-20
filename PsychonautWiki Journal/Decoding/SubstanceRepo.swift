import Foundation
import CoreData

class SubstanceRepo: ObservableObject {

    static let shared = SubstanceRepo()

    @Published var substances: [Substance]
    @Published var lastUpdated: Date

    init() {
        let data = SubstanceRepo.getInitialData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        decoder.keyDecodingStrategy = .useDefaultKeys
        // swiftlint:disable force_try
        substances = try! decoder.decode([Substance].self, from: data)
        lastUpdated = SubstanceRepo.getCreationDate()
    }

    static private func getCreationDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 4
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "CEST")
        dateComponents.hour = 13
        dateComponents.minute = 52
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: dateComponents) ?? Date()
    }

    static private func getInitialData() -> Data {
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }
        return data
    }

}
