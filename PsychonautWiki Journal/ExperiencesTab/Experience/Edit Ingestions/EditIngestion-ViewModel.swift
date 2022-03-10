import Foundation

extension EditIngestionView {
    class ViewModel: ObservableObject {
        var ingestion: Ingestion?
        @Published var selectedAdministrationRoute: AdministrationRoute = .oral {
            didSet {
                ingestion?.administrationRoute = selectedAdministrationRoute.rawValue
                if let newUnits = ingestion?.substance?.getDose(for: selectedAdministrationRoute)?.units {
                    selectedUnits = newUnits
                }
            }
        }
        @Published var selectedDose: Double? {
            didSet {
                if let doseDouble = selectedDose {
                    ingestion?.dose = doseDouble
                }
            }
        }
        @Published var selectedUnits: String? {
            didSet {
                ingestion?.units = selectedUnits
            }
        }
        @Published var selectedColor: IngestionColor = .blue {
            didSet {
                ingestion?.color = selectedColor.rawValue
            }
        }
        @Published var selectedTime = Date() {
            didSet {
                ingestion?.time = selectedTime
            }
        }
        @Published var selectedName = "" {
            didSet {
                ingestion?.substanceName = selectedName
            }
        }

        var roaDose: RoaDose? {
            ingestion?.substance?.getDose(for: selectedAdministrationRoute)
        }

        init() {}

        func initialize(ingestion: Ingestion) {
            self.ingestion = ingestion
            self.selectedAdministrationRoute = ingestion.administrationRouteUnwrapped
            self.selectedDose = ingestion.doseUnwrapped
            self.selectedUnits = ingestion.unitsUnwrapped
            self.selectedColor = ingestion.colorUnwrapped
            self.selectedTime = ingestion.timeUnwrapped
            self.selectedName = ingestion.substanceNameUnwrapped
        }
    }
}
