import Foundation

extension EditIngestionView {
    class ViewModel: ObservableObject {
        var ingestion: Ingestion?
        @Published var selectedAdministrationRoute: Roa.AdministrationRoute = .oral
        @Published var selectedDose: Double?
        @Published var selectedColor: Ingestion.IngestionColor = .blue
        @Published var selectedTime: Date = Date()

        var roaDose: RoaDose? {
            ingestion?.substance?.getDose(for: selectedAdministrationRoute)
        }

        init() {}

        func updateAndSave() {
            ingestion?.experience?.objectWillChange.send()
            ingestion?.time = selectedTime
            if let doseDouble = selectedDose {
                ingestion?.dose = doseDouble
            }
            ingestion?.administrationRoute = selectedAdministrationRoute.rawValue
            ingestion?.color = selectedColor.rawValue
            PersistenceController.shared.saveViewContext()
        }
    }
}
