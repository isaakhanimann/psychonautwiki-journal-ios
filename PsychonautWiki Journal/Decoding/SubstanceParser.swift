import Foundation
import CoreData

class SubstanceParser: ObservableObject {

    @Published var substances: [Substance]
    @Published var lastUpdated: Date

    init() {
        let data = SubstanceParser.getInitialData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        decoder.keyDecodingStrategy = .useDefaultKeys
        // swiftlint:disable force_try
        let dataForSubstances = try! SubstanceParser.getDataForSubstances(from: data)
        substances = try! decoder.decode([Substance].self, from: dataForSubstances)
        lastUpdated = SubstanceParser.getCreationDate()
    }

    static private func getDataForSubstances(from fileData: Data) throws -> Data {
        guard let json = try JSONSerialization.jsonObject(with: fileData, options: []) as? [String: Any],
              let fileObject = json["data"] else {
                  throw ConversionError.failedToConvertDataToJSON
              }
        return try JSONSerialization.data(withJSONObject: fileObject)
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
