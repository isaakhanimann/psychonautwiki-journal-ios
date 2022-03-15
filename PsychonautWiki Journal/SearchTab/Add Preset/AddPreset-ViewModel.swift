import Foundation

extension AddPresetView {

    class ViewModel: ObservableObject {

        @Published var presetName = ""
        @Published var units: String?
        @Published var components: [Component] = []
        @Published var isShowingAddComponentSheet = false

        func addComponentToList(component: Component) {
            components.append(component)
        }

        func dismissComponentView() {
            isShowingAddComponentSheet.toggle()
        }

        func savePreset() {
            let context = PersistenceController.shared.viewContext
            let preset = Preset(context: context)
            preset.name = presetName
            preset.units = units
        }
    }
}
