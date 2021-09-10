import Foundation
import CoreData

public class Roa: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case name, dose, duration
    }

    // https://psychonautwiki.org/wiki/Route_of_administration
    enum AdministrationRoute: String, Codable, CaseIterable {
        case oral
        case sublingual
        case buccal
        case insufflated
        case rectal
        case transdermal
        case subcutaneous
        case intramuscular
        case intravenous
        case smoked
        case inhaled

        var displayString: String {
            switch self {
            case .oral:
                return "oral (swallowed)"
            case .sublingual:
                return "sublingual (under the tongue)"
            case .buccal:
                return "buccal (between gums and cheek)"
            case .insufflated:
                return "insufflated (sniffed)"
            case .rectal:
                return "rectal"
            case .transdermal:
                return "transdermal (through skin)"
            case .subcutaneous:
                return "subcutaneous (injected)"
            case .intramuscular:
                return "intramuscular (injected)"
            case .intravenous:
                return "intravenous (injected)"
            case .smoked:
                return "smoked"
            case .inhaled:
                return "inhaled"
            }
        }
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(AdministrationRoute.self, forKey: .name).rawValue
        if let doseTypesUnwrapped = try? container.decodeIfPresent(DoseTypes.self, forKey: .dose) {
            self.doseTypes = doseTypesUnwrapped
        } else {
            self.doseTypes = DoseTypes.createDefault(moc: context)
        }
        self.durationTypes = try container.decode(DurationTypes.self, forKey: .duration)
    }
}
