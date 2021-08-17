import Foundation
import CoreData

public class DurationTypes: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case onset, comeup, peak, offset, total, afterglow
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.onset = try container.decode(DurationRange.self, forKey: .onset)
        self.comeup = try container.decode(DurationRange.self, forKey: .comeup)
        self.peak = try container.decode(DurationRange.self, forKey: .peak)
        self.offset = try container.decode(DurationRange.self, forKey: .offset)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(onset, forKey: .onset)
        try container.encode(comeup, forKey: .comeup)
        try container.encode(peak, forKey: .peak)
        try container.encode(offset, forKey: .offset)
    }
}
