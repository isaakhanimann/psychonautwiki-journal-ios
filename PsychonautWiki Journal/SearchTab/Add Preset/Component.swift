import Foundation

struct Component: Identifiable {
    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dose: Double
    let units: String
    // swiftlint:disable identifier_name
    let id: UUID
}
