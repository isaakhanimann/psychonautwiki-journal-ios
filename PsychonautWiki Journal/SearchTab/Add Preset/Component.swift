import Foundation

struct Component: Identifiable {
    var substance: Substance
    var administrationRoute: AdministrationRoute
    var dose: Double
    // swiftlint:disable identifier_name
    let id: UUID
}
