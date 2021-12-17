import Foundation
import CoreData

public class DurationTypes: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case onset, comeup, peak, offset, total, afterglow
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let onset = try container.decode(DurationRange.self, forKey: .onset)
        let comeup = try container.decode(DurationRange.self, forKey: .comeup)
        let peak = try container.decode(DurationRange.self, forKey: .peak)
        let offset = try container.decode(DurationRange.self, forKey: .offset)
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.onset = onset
        self.comeup = comeup
        self.peak = peak
        self.offset = offset
    }
}
