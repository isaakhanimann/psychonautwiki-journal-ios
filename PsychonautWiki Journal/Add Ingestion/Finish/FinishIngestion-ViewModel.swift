import Foundation
import CoreData

extension FinishIngestionScreen {

    @MainActor
    class ViewModel: ObservableObject {

        @Published var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        @Published var selectedTime = Date()
        @Published var enteredNote = ""
        @Published var isAddingToFoundExperience = true
        @Published var alreadyUsedColors = Set<SubstanceColor>()
        @Published var otherColors = Set<SubstanceColor>()
        @Published var notesInOrder = [String]()
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
            hasInitializedAlready = true
        }

        func addIngestion(
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool
        ) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let companion = createOrUpdateCompanion(with: context, substanceName: substanceName)
                if let existingExperience = closestExperience, isAddingToFoundExperience {
                    createIngestion(
                        with: existingExperience,
                        and: context,
                        substanceName: substanceName,
                        administrationRoute: administrationRoute,
                        dose: dose,
                        units: units,
                        isEstimate: isEstimate,
                        substanceCompanion: companion
                    )
                    if #available(iOS 16.2, *) {
                        if existingExperience.isCurrent {
                            ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: existingExperience.sortedIngestionsUnwrapped))
                        }
                    }
                } else {
                    let newExperience = Experience(context: context)
                    newExperience.creationDate = Date()
                    newExperience.sortDate = selectedTime
                    newExperience.title = selectedTime.asDateString
                    newExperience.text = ""
                    createIngestion(
                        with: newExperience,
                        and: context,
                        substanceName: substanceName,
                        administrationRoute: administrationRoute,
                        dose: dose,
                        units: units,
                        isEstimate: isEstimate,
                        substanceCompanion: companion
                    )
                    if #available(iOS 16.2, *) {
                        if newExperience.isCurrent {
                            ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: newExperience.sortedIngestionsUnwrapped))
                        }
                    }
                }
                try? context.save()
            }
        }


        private func createOrUpdateCompanion(with context: NSManagedObjectContext, substanceName: String) -> SubstanceCompanion {
            if let foundCompanion {
                foundCompanion.colorAsText = selectedColor.rawValue
                return foundCompanion
            } else {
                let companion = SubstanceCompanion(context: context)
                companion.substanceName = substanceName
                companion.colorAsText = selectedColor.rawValue
                return companion
            }
        }

        private func createIngestion(
            with experience: Experience,
            and context: NSManagedObjectContext,
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool,
            substanceCompanion: SubstanceCompanion
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
            ingestion.substanceCompanion = substanceCompanion
        }

        @Published var closestExperience: Experience?

        init() {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            ingestionFetchRequest.predicate = NSPredicate(format: "note.length > 0")
            ingestionFetchRequest.fetchLimit = 15
            let sortedIngestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
            notesInOrder = sortedIngestions.map { ing in
                ing.noteUnwrapped
            }.uniqued()
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
