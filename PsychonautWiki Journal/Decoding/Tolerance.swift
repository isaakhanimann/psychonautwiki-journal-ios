import Foundation
import CoreData

struct Tolerance: Decodable {

    let full: String?
    let half: String?
    let zero: String?

    enum CodingKeys: String, CodingKey {
        case full, half, zero
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.full = try? container.decodeIfPresent(String.self, forKey: .full)
        self.half = try? container.decodeIfPresent(String.self, forKey: .half)
        self.zero = try? container.decodeIfPresent(String.self, forKey: .zero)
    }

    var isAtLeastOneDefined: Bool {
        if let zeroUnwrap = zero, !zeroUnwrap.isEmpty {
            return true
        }
        if let halfUnwrap = half, !halfUnwrap.isEmpty {
            return true
        }
        if let fullUnwrap = full, !fullUnwrap.isEmpty {
            return true
        }
        return false
    }
}
