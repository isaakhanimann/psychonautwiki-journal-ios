import Foundation
import CoreData

public class DoseTypes: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case units, threshold, light, common, strong, heavy
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.units = try container.decode(String.self, forKey: .units)
        self.threshold = (try? container.decode(Double.self, forKey: .threshold)) ?? 0
        if let lightUnwrapped = try? container.decode(DoseRange.self, forKey: .light) {
            self.light = lightUnwrapped
        } else {
            self.light = DoseRange.createDefault(moc: context, addTo: self)
        }
        if let commonUnwrapped = try? container.decode(DoseRange.self, forKey: .common) {
            self.common = commonUnwrapped
        } else {
            self.common = DoseRange.createDefault(moc: context, addTo: self)
        }
        if let strongUnwrapped = try? container.decode(DoseRange.self, forKey: .strong) {
            self.strong = strongUnwrapped
        } else {
            self.strong = DoseRange.createDefault(moc: context, addTo: self)
        }
        self.heavy = (try? container.decode(Double.self, forKey: .heavy)) ?? 0
    }
}
