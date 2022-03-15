import Foundation

extension PresetComponent {

    var substanceNameUnwrapped: String {
        substanceName ?? "Unknown"
    }

    var administrationRouteUnwrapped: AdministrationRoute? {
        AdministrationRoute(rawValue: administrationRoute ?? "")
    }

    var dosePerUnitUnwrapped: Double? {
        if dosePerUnit == 0 {
            return nil
        } else {
            return dosePerUnit
        }
    }
}
