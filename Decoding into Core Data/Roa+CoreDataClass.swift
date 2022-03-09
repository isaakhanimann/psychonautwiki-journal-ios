import Foundation
import CoreData

public class Roa: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case name, dose, duration, bioavailability
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(AdministrationRoute.self, forKey: .name).rawValue
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.name = name
        self.dose = try? container.decodeIfPresent(RoaDose.self, forKey: .dose)
        self.duration = try? container.decodeIfPresent(RoaDuration.self, forKey: .duration)
        self.bioavailability = try? container.decodeIfPresent(RoaRange.self, forKey: .bioavailability)
    }
}
