import Foundation
import CoreData

public class Tolerance: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case full, half, zero
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(context: context)
        self.full = try? container.decodeIfPresent(String.self, forKey: .full)
        self.half = try? container.decodeIfPresent(String.self, forKey: .half)
        self.zero = try? container.decodeIfPresent(String.self, forKey: .zero)
    }
}
