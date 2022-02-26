import Foundation
import CoreData

extension Roa {

    var nameUnwrapped: AdministrationRoute {
        AdministrationRoute(rawValue: name ?? "") ?? .oral
    }

}
