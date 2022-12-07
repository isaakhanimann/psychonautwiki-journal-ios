import Foundation
import CoreData

struct RoaRange: Decodable {

    let min: Double?
    let max: Double?

    var displayString: String? {
        guard min != nil || min != nil else {return nil}
        let min = min?.formatted() ?? ".."
        let max = max?.formatted() ?? ".."
        return "\(min)-\(max)"
    }
}
