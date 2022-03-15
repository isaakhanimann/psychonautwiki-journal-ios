import Foundation

extension PresetComponent {

    var substanceNameUnwrapped: String {
        substanceName ?? "Unknown"
    }

    var administrationRouteUnwrapped: AdministrationRoute? {
        AdministrationRoute(rawValue: administrationRoute ?? "")
    }

    var unitsUnwrapped: String {
        units ?? ""
    }

    var dosePerUnitOfPresetUnwrapped: Double? {
        if dosePerUnitOfPreset == 0 {
            return nil
        } else {
            return dosePerUnitOfPreset
        }
    }
}
