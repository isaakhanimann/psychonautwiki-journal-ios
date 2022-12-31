import Foundation
import CoreData

extension FinishIngestionScreen {

    @MainActor
    class ViewModel: ObservableObject {

        @Published var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        @Published var selectedTime = Date()
        @Published var enteredNote = ""
        @Published var isLoadingCompanions = true
        @Published var isAddingToFoundExperience = true
        @Published var alreadyUsedColors = Set<SubstanceColor>()
        @Published var otherColors = Set<SubstanceColor>()
        private var foundCompanion: SubstanceCompanion? = nil
        private var hasInitializedAlready = false

        func initializeColorAndHasCompanion(for substanceName: String) {
            guard !hasInitializedAlready else {return} // because this function is going to be called again when navigating back from color picker screen
            let fetchRequest = SubstanceCompanion.fetchRequest()
            let companions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            alreadyUsedColors = Set(companions.map { $0.color })
            otherColors = Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)
            let companionMatch = companions.first { comp in
                comp.substanceNameUnwrapped == substanceName
            }
            if let companionMatchUnwrap = companionMatch {
                foundCompanion = companionMatchUnwrap
                self.selectedColor = companionMatchUnwrap.color
            } else {
                self.selectedColor = otherColors.first ?? SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
            }
            isLoadingCompanions = false
            hasInitializedAlready = true
        }

        func addIngestion(
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool
        ) {
            if let experience = closestExperience, isAddingToFoundExperience {
                addIngestion(
                    to: experience,
                    substanceName: substanceName,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    units: units,
                    isEstimate: isEstimate
                )
            } else {
                addIngestionToNewExperience(
                    substanceName: substanceName,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    units: units,
                    isEstimate: isEstimate
                )
            }
        }

        private func addIngestion(
            to experience: Experience,
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool
        ) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                createOrUpdateCompanion(with: context, substanceName: substanceName)
                createIngestion(
                    with: experience,
                    and: context,
                    substanceName: substanceName,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    units: units,
                    isEstimate: isEstimate
                )
                try? context.save()
            }
        }

        private func addIngestionToNewExperience(
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool
        ) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                createOrUpdateCompanion(with: context, substanceName: substanceName)
                let experience = Experience(context: context)
                experience.creationDate = Date()
                experience.sortDate = selectedTime
                experience.title = selectedTime.asDateString
                experience.text = ""
                createIngestion(
                    with: experience,
                    and: context,
                    substanceName: substanceName,
                    administrationRoute: administrationRoute,
                    dose: dose,
                    units: units,
                    isEstimate: isEstimate
                )
                try? context.save()
            }
        }

        private func createOrUpdateCompanion(with context: NSManagedObjectContext, substanceName: String) {
            if let foundCompanion {
                foundCompanion.colorAsText = selectedColor.rawValue
            } else {
                let companion = SubstanceCompanion(context: context)
                companion.substanceName = substanceName
                companion.colorAsText = selectedColor.rawValue
            }
        }

        private func createIngestion(
            with experience: Experience,
            and context: NSManagedObjectContext,
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool
        ) {
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.creationDate = Date()
            ingestion.dose = dose ?? 0
            ingestion.units = units
            ingestion.isEstimate = isEstimate
            ingestion.note = enteredNote
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
                fetchRequest.predicate = FinishIngestionScreen.ViewModel.getPredicate(from: date)
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
