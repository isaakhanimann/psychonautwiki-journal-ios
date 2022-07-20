import Foundation
import CoreData

struct Roa: Decodable {

    let name: AdministrationRoute
    let dose: RoaDose?
    let duration: RoaDuration?
    let bioavailability: RoaRange?

    enum CodingKeys: String, CodingKey {
        case name, dose, duration, bioavailability
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(AdministrationRoute.self, forKey: .name)
        self.dose = try? container.decodeIfPresent(RoaDose.self, forKey: .dose)
        self.duration = try? container.decodeIfPresent(RoaDuration.self, forKey: .duration)
        self.bioavailability = try? container.decodeIfPresent(RoaRange.self, forKey: .bioavailability)
    }
}
