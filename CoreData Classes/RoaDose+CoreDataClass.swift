import Foundation
import CoreData

public class RoaDose: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case units, threshold, light, common, strong, heavy
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let units = try container.decode(String.self, forKey: .units)
        let threshold = (try? container.decode(Double.self, forKey: .threshold))
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.units = units
        self.threshold = threshold ?? 0
        self.light = try? container.decode(RoaRange.self, forKey: .light)
        self.common = try? container.decode(RoaRange.self, forKey: .common)
        self.strong = try? container.decode(RoaRange.self, forKey: .strong)
        self.heavy = (try? container.decode(Double.self, forKey: .heavy)) ?? 0
    }
}
