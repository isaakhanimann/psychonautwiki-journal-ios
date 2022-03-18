import Foundation

extension AddComponentView {

    class ViewModel: ObservableObject {

        let sortedSubstances: [Substance]
        @Published var selectedSubstance: Substance {
            didSet {
                administrationRoute = selectedSubstance.administrationRoutesUnwrapped.first ?? AdministrationRoute.oral
            }
        }
        @Published var administrationRoute = AdministrationRoute.oral {
            didSet {
                selectedUnit = roaDose?.units
            }
        }
        @Published var dosePerUnit: Double?
        @Published var selectedUnit: String?

        var roaDose: RoaDose? {
            selectedSubstance.getDose(for: administrationRoute)
        }

        var isEverythingNeededDefined: Bool {
            guard dosePerUnit != nil else {return false}
            guard selectedUnit != nil else {return false}
            return true
        }

        init() {
            let fetchRequest = Substance.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Substance.name, ascending: true) ]
            let substances = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            let isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey)
            sortedSubstances = getOkSubstances(substancesToFilter: substances, isEyeOpen: isEyeOpen)
            selectedSubstance = sortedSubstances.first!
            selectedUnit = roaDose?.units
        }

        func getComponent() -> Component {
            assert(isEverythingNeededDefined, "Tried to add component without defining the necessary fields")
            return Component(
                substance: selectedSubstance,
                administrationRoute: administrationRoute,
                dose: dosePerUnit ?? 0,
                units: selectedUnit ?? "",
                id: UUID()
            )
        }

    }
}
