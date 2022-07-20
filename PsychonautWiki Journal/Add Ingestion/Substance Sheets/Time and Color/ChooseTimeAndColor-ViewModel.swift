import Foundation
import CoreData

extension ChooseTimeAndColor {

    class ViewModel: ObservableObject {

        @Published var lastExperience: Experience?
        @Published var selectedColor = IngestionColor.allCases.randomElement() ?? IngestionColor.blue
        @Published var selectedTime = Date()
        var substance: Substance?
        var administrationRoute = AdministrationRoute.allCases.randomElement() ?? AdministrationRoute.oral
        var dose: Double = 0
        var units: String?

        func setDefaultColor() {
            let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            guard let name = substance?.name else { return }
            fetchRequest.predicate = NSPredicate(format: "substanceName == %@", name)
            fetchRequest.fetchLimit = 1
            let ingestions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            if let color = ingestions.first?.colorUnwrapped {
                self.selectedColor = color
            }
        }

        func addIngestion(to experience: Experience) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let ingestion = createIngestion()
                experience.addToIngestions(ingestion)
                try? context.save()
            }
        }

        func addIngestionToNewExperience() {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let newExperience = Experience(context: context)
                let now = Date()
                newExperience.creationDate = now
                newExperience.title = now.asDateString
                let ingestion = createIngestion()
                newExperience.addToIngestions(ingestion)
                try? context.save()
            }
        }

        private func createIngestion() -> Ingestion {
            let context = PersistenceController.shared.viewContext
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.dose = dose
            ingestion.units = units
            ingestion.administrationRoute = administrationRoute.rawValue
            ingestion.substanceName = substance?.name
            ingestion.color = selectedColor.rawValue
            return ingestion
        }
    }
}
