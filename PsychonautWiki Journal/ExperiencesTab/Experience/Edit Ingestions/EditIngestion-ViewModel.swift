import Foundation

extension EditIngestionView {
    class ViewModel: ObservableObject {
        var ingestion: Ingestion?
        @Published var selectedAdministrationRoute: Roa.AdministrationRoute = .oral {
            didSet {
                ingestion?.administrationRoute = selectedAdministrationRoute.rawValue
                if let newUnits = ingestion?.substance?.getDose(for: selectedAdministrationRoute)?.units {
                    ingestion?.units = newUnits
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
        @Published var selectedColor: Ingestion.IngestionColor = .blue {
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
            self.selectedColor = ingestion.colorUnwrapped
            self.selectedTime = ingestion.timeUnwrapped
            self.selectedName = ingestion.substanceNameUnwrapped
        }
    }
}
