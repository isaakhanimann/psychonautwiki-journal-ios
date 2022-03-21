import Foundation

extension AddCustomSubstanceView {

    class ViewModel: ObservableObject {
        @Published var name = ""
        @Published var units: String? = "mg"

        var isEverythingNeededDefined: Bool {
            guard !name.isEmpty else {return false}
            guard let unitsUnwrap = units, !unitsUnwrap.isEmpty else {return false}
            return true
        }

        func saveCustom() {
            assert(isEverythingNeededDefined, "Tried to save custom substance without defining the necessary fields")
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let custom = CustomSubstance(context: context)
                custom.name = name
                custom.units = units
                try? context.save()
            }
        }
    }
}
