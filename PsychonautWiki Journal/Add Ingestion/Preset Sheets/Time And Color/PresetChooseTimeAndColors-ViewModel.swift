import Foundation
import CoreData

extension PresetChooseTimeAndColorsView {

    struct ComponentColorCombo: Identifiable {
        let component: PresetComponent
        var selectedColor = IngestionColor.allCases.randomElement() ?? IngestionColor.blue

        // swiftlint:disable identifier_name
        var id: ObjectIdentifier {
            component.id
        }

        init(component: PresetComponent) {
            self.component = component
            let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            let name = component.substanceNameUnwrapped
            fetchRequest.predicate = NSPredicate(format: "substanceName == %@", name)
            fetchRequest.fetchLimit = 1
            let ingestions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            if let color = ingestions.first?.colorUnwrapped {
                self.selectedColor = color
            }
        }
    }

    class ViewModel: ObservableObject {

        @Published var selectedTime = Date()
        @Published var componentColorCombos: [ComponentColorCombo] = []
        @Published var lastExperience: Experience?
        var presetDose: Double = 0

        func addIngestions(to experience: Experience) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let ingestions = createIngestions()
                experience.addToIngestions(NSSet(array: ingestions))
                try? context.save()
            }
        }

        func addIngestionsToNewExperience() {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let newExperience = Experience(context: context)
                let now = Date()
                newExperience.creationDate = now
                newExperience.title = now.asDateString
                let ingestions = createIngestions()
                newExperience.addToIngestions(NSSet(array: ingestions))
                try? context.save()
            }
        }

        private func createIngestions() -> [Ingestion] {
            let ingestions = componentColorCombos.map { combo in
                createOneIngestion(from: combo)
            }
            return ingestions
        }

        private func createOneIngestion(from combo: ComponentColorCombo) -> Ingestion {
            let context = PersistenceController.shared.viewContext
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.dose = presetDose * combo.component.dosePerUnitOfPreset
            ingestion.units = combo.component.units
            ingestion.administrationRoute = combo.component.administrationRoute
            ingestion.substanceName = combo.component.substanceName
            ingestion.color = combo.selectedColor.rawValue
            return ingestion
        }
    }
}
