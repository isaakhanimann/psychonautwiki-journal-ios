import Foundation
import CoreData

public class RoaDuration: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case onset, comeup, peak, offset, total, afterglow
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.onset = try? container.decodeIfPresent(DurationRange.self, forKey: .onset)
        self.comeup = try? container.decodeIfPresent(DurationRange.self, forKey: .comeup)
        self.peak = try? container.decodeIfPresent(DurationRange.self, forKey: .peak)
        self.offset = try? container.decodeIfPresent(DurationRange.self, forKey: .offset)
        self.total = try? container.decodeIfPresent(DurationRange.self, forKey: .total)
        self.afterglow = try? container.decodeIfPresent(DurationRange.self, forKey: .afterglow)
    }
}
