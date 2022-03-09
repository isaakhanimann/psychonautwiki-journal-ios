import Foundation
import CoreData

extension ChooseTimeAndColor {

    class ViewModel: ObservableObject {

        @Published var lastExperience: Experience?
        @Published var selectedColor = Ingestion.IngestionColor.blue
        @Published var selectedTime = Date()
        var substance: Substance?
        var administrationRoute = Roa.AdministrationRoute.allCases.randomElement() ?? Roa.AdministrationRoute.oral
        var dose: Double = 0
        var dismiss: (AddResult) -> Void = {print($0)}

        func initialize(
            substance: Substance,
            administrationRoute: Roa.AdministrationRoute,
            dose: Double,
            dismiss: @escaping (AddResult) -> Void,
            experience: Experience?
        ) {
            self.substance = substance
            self.administrationRoute = administrationRoute
            self.dose = dose
            self.dismiss = dismiss
            if experience == nil {
                setLastExperience()
            }
            setDefaultColor()
        }

        func setLastExperience() {
            let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
            fetchRequest.fetchLimit = 10
            let experiences = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            self.lastExperience = experiences.sorted().first
        }

        func setDefaultColor() {
            let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            guard let name = substance?.nameUnwrapped else { return }
            fetchRequest.predicate = NSPredicate(format: "substanceName == %@", name)
            fetchRequest.fetchLimit = 1
            let ingestions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            if let color = ingestions.first?.colorUnwrapped {
                self.selectedColor = color
            }
        }

        func addIngestionSaveAndDismiss(to experience: Experience) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let ingestion = createIngestion()
                experience.addToIngestions(ingestion)
                try? context.save()
            }
            dismiss(.ingestionWasAdded)
        }

        func addIngestionToNewExperienceSaveAndDismiss() {
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
            dismiss(.ingestionWasAdded)
        }

        private func createIngestion() -> Ingestion {
            let context = PersistenceController.shared.viewContext
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.dose = dose
            ingestion.units = substance?.getDose(for: administrationRoute)?.units
            ingestion.administrationRoute = administrationRoute.rawValue
            ingestion.substanceName = substance?.nameUnwrapped
            ingestion.color = selectedColor.rawValue
            return ingestion
        }
    }
}
