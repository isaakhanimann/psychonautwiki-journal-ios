import Foundation

extension Preset {

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var unitsUnwrapped: String {
        units ?? "Unknown"
    }

    var componentsUnwrapped: [PresetComponent] {
        components?.allObjects as? [PresetComponent] ?? []
    }
}
