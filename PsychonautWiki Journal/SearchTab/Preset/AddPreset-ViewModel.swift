import Foundation

extension AddPresetView {

    class ViewModel: ObservableObject {

        @Published var presetName = ""
        @Published var units: String? = ""
        @Published var components: [Component] = []
        @Published var isShowingAddComponentSheet = false

        var isEverythingNeededDefined: Bool {
            guard !presetName.isEmpty else {return false}
            guard let unitsUnwrap = units, !unitsUnwrap.isEmpty else {return false}
            guard !components.isEmpty else {return false}
            return true
        }

        func addComponentToList(component: Component) {
            components.append(component)
        }

        func savePreset() {
            assert(isEverythingNeededDefined, "Tried to save preset without defining the necessary fields")
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let preset = Preset(context: context)
                preset.name = presetName
                preset.units = units
                let presetComponents = components.map { com -> PresetComponent in
                    let presetCom = PresetComponent(context: context)
                    presetCom.administrationRoute = com.administrationRoute.rawValue
                    presetCom.dosePerUnitOfPreset = com.dose
                    presetCom.units = com.units
                    presetCom.substanceName = com.substance.nameUnwrapped
                    return presetCom
                }
                let componentSet = NSSet(array: presetComponents)
                preset.addToComponents(componentSet)
                try? context.save()
            }
        }
    }
}
