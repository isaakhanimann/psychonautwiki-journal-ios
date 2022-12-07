import Foundation
import CoreData

struct Roa: Decodable {
    let name: AdministrationRoute
    let dose: RoaDose?
    let duration: RoaDuration?
    let bioavailability: RoaRange?
}
