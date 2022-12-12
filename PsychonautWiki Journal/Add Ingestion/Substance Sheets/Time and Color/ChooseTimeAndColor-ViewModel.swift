import Foundation
import CoreData

extension ChooseTimeAndColor {

    class ViewModel: ObservableObject {

        @Published var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        @Published var selectedTime = Date()
        @Published var isLoadingCompanions = true
        @Published var isAddingToFoundExperience = true
        @Published var alreadyUsedColors = Set<SubstanceColor>()
        @Published var otherColors = Set<SubstanceColor>()
        @Published var doesCompanionExistAlready = true
        var substanceName: String?
        var administrationRoute = AdministrationRoute.allCases.randomElement() ?? AdministrationRoute.oral
        var dose: Double = 0
        var units: String?

        func initializeColorAndHasCompanion(for substanceName: String) {
            let fetchRequest = SubstanceCompanion.fetchRequest()
            let companions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            alreadyUsedColors = Set(companions.map { $0.color })
            otherColors = Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)
            let companionMatch = companions.first { comp in
                comp.substanceNameUnwrapped == substanceName
            }
            if let companionMatchUnwrap = companionMatch {
                doesCompanionExistAlready = true
                self.selectedColor = companionMatchUnwrap.color
            } else {
                doesCompanionExistAlready = false
                self.selectedColor = otherColors.first ?? SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
            }
            isLoadingCompanions = false
        }

        func addIngestion() {
            if let experience = closestExperience, isAddingToFoundExperience {
                addIngestion(to: experience)
            } else {
                addIngestionToNewExperience()
            }
        }

        private func addIngestion(to experience: Experience) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                maybeCreateCompanion(with: context)
                createIngestion(with: experience, and: context)
                try? context.save()
            }
        }

        private func addIngestionToNewExperience() {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                maybeCreateCompanion(with: context)
                let experience = Experience(context: context)
                experience.creationDate = Date()
                experience.sortDate = selectedTime
                experience.title = selectedTime.asDateString
                experience.text = ""
                createIngestion(with: experience, and: context)
                try? context.save()
            }
        }

        private func maybeCreateCompanion(with context: NSManagedObjectContext) {
            if !doesCompanionExistAlready {
                let companion = SubstanceCompanion(context: context)
                companion.substanceName = substanceName
                companion.colorAsText = selectedColor.rawValue
            }
        }

        private func createIngestion(with experience: Experience, and context: NSManagedObjectContext) {
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.creationDate = Date()
            ingestion.dose = dose
            ingestion.units = units
            ingestion.administrationRoute = administrationRoute.rawValue
            ingestion.substanceName = substanceName
            ingestion.color = selectedColor.rawValue
            ingestion.experience = experience
        }

        @Published var closestExperience: Experience?

        init() {
            $selectedTime.map({ date in
                let fetchRequest = Ingestion.fetchRequest()
                fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = ChooseTimeAndColor.ViewModel.getPredicate(from: date)
                return try? PersistenceController.shared.viewContext.fetch(fetchRequest).first?.experience
            }).assign(to: &$closestExperience)
        }

        private static func getPredicate(from date: Date) -> NSCompoundPredicate {
            let halfDay: TimeInterval = 12*60*60
            let startDate = date.addingTimeInterval(-halfDay)
            let endDate = date.addingTimeInterval(halfDay)
            let laterThanStart = NSPredicate(format: "time > %@", startDate as NSDate)
            let earlierThanEnd = NSPredicate(format: "time < %@", endDate as NSDate)
            return NSCompoundPredicate(
                andPredicateWithSubpredicates: [laterThanStart, earlierThanEnd]
            )
        }
    }
}
