import Foundation
import CoreData

struct RoaRange: Decodable {

    let min: Double?
    let max: Double?

    enum CodingKeys: String, CodingKey {
        case min, max
    }

    enum DecodingError: Error {
        case minBiggerThanMax
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let min = (try? container.decodeIfPresent(Double.self, forKey: .min)) ?? 0
        let max = (try? container.decodeIfPresent(Double.self, forKey: .max)) ?? 0
        if min > max {
            throw DecodingError.minBiggerThanMax
        }
        self.min = min
        self.max = max
    }

    var displayString: String? {
        guard min != nil || min != nil else {return nil}
        let min = min?.formatted() ?? ".."
        let max = max?.formatted() ?? ".."
        return "\(min)-\(max)"
    }
}
