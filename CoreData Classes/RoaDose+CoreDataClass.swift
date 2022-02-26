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
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.units = try? container.decodeIfPresent(String.self, forKey: .units)
        self.threshold = (try? container.decodeIfPresent(Double.self, forKey: .threshold)) ?? 0
        self.light = try? container.decodeIfPresent(RoaRange.self, forKey: .light)
        self.common = try? container.decodeIfPresent(RoaRange.self, forKey: .common)
        self.strong = try? container.decodeIfPresent(RoaRange.self, forKey: .strong)
        self.heavy = (try? container.decodeIfPresent(Double.self, forKey: .heavy)) ?? 0
    }
}
