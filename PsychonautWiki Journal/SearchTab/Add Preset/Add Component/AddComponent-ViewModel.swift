import Foundation

extension AddComponentView {

    class ViewModel: ObservableObject {

        let sortedSubstances: [Substance]
        @Published var selectedSubstance: Substance {
            didSet {
                administrationRoute = selectedSubstance.administrationRoutesUnwrapped.first ?? AdministrationRoute.oral
            }
        }
        @Published var administrationRoute = AdministrationRoute.oral
        @Published var dosePerUnit: Double?
        @Published var selectedUnitDummy: String?

        var roaDose: RoaDose? {
            selectedSubstance.getDose(for: administrationRoute)
        }

        init() {
            let fetchRequest = Substance.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Substance.name, ascending: true) ]
            let substances = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            self.sortedSubstances = substances
            selectedSubstance = substances.first!
        }

        func getComponent() -> Component {
            return Component(
                substance: selectedSubstance,
                administrationRoute: administrationRoute,
                dose: dosePerUnit ?? 0,
                id: UUID()
            )
        }

    }
}
