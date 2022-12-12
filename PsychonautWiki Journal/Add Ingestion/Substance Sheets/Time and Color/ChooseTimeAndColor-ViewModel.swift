import Foundation
import CoreData

extension ChooseTimeAndColor {

    class ViewModel: ObservableObject {

        @Published var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        @Published var selectedTime = Date()
        @Published var isLoadingCompanions = true
        var doesCompanionExistAlready = true
        var substance: Substance?
        var administrationRoute = AdministrationRoute.allCases.randomElement() ?? AdministrationRoute.oral
        var dose: Double = 0
        var units: String?

        func setDefaultColor() {
            let fetchRequest = SubstanceCompanion.fetchRequest()
            guard let name = substance?.name else { return }
            let companions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            let maybeColor = companions.first { comp in
                comp.substanceNameUnwrapped == name
            }?.color
            if let color = maybeColor {
                doesCompanionExistAlready = true
                self.selectedColor = color
            } else {
                doesCompanionExistAlready = false
                let usedColors = companions.compactMap { comp in
                    comp.color
                }
                let otherColors = Set(SubstanceColor.allCases).subtracting(usedColors)
                self.selectedColor = otherColors.first ?? SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
            }
            isLoadingCompanions = false
        }

        func addIngestionToNewExperience() {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                if !doesCompanionExistAlready {
                    let companion = SubstanceCompanion(context: context)
                    companion.substanceName = substance?.name
                    companion.colorAsText = selectedColor.rawValue
                }
                let experience = Experience(context: context)
                experience.creationDate = Date()
                experience.sortDate = selectedTime
                experience.title = selectedTime.asDateString
                experience.text = ""
                let ingestion = Ingestion(context: context)
                ingestion.identifier = UUID()
                ingestion.time = selectedTime
                ingestion.creationDate = Date()
                ingestion.dose = dose
                ingestion.units = units
                ingestion.administrationRoute = administrationRoute.rawValue
                ingestion.substanceName = substance?.name
                ingestion.color = selectedColor.rawValue
                ingestion.experience = experience
                try? context.save()
            }
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
