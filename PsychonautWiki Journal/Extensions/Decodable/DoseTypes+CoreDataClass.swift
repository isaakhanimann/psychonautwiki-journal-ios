import Foundation
import CoreData

public class DoseTypes: NSManagedObject, Codable {

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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(units, forKey: .units)
        try container.encode(threshold, forKey: .threshold)
        try container.encode(light, forKey: .light)
        try container.encode(common, forKey: .common)
        try container.encode(strong, forKey: .strong)
        try container.encode(heavy, forKey: .heavy)
    }
}
