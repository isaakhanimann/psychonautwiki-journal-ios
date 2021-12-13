import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer
    let viewContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    static let hasBeenSetupBeforeKey = "hasBeenSetupBefore"
    static let isEyeOpenKey = "isEyeOpen"
    static let needsToUpdateWatchFaceKey = "needsToUpdateWatchFace"

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Main", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
        viewContext = container.viewContext
        backgroundContext = container.newBackgroundContext()
    }

    func createPreviewHelper() -> PreviewHelper {
        PreviewHelper(context: container.viewContext)
    }

    func findSubstance(with name: String) -> Substance? {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        guard let file = try? container.viewContext.fetch(fetchRequest).first else {return nil}
        return file.getSubstance(with: name)
    }

    func findGeneralInteraction(with name: String) -> GeneralInteraction? {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        guard let file = try? container.viewContext.fetch(fetchRequest).first else {return nil}
        return file.getGeneralInteraction(with: name)
    }

    func getLatestExperience() -> Experience? {
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
        guard let experiences = try? container.viewContext.fetch(fetchRequest) else {return nil}
        return experiences.first
    }

    func getOrCreateLatestExperience() -> Experience? {
        if let resultExperience = getLatestExperience() {
            if !resultExperience.isOver {
                return resultExperience
            } else {
                return createNewExperienceNow()
            }
        } else {
            return createNewExperienceNow()
        }
    }

    func getOrCreateLatestExperienceWithoutSave() -> Experience {
        if let resultExperience = getLatestExperience() {
            if !resultExperience.isOver {
                return resultExperience
            } else {
                return createNewExperienceNowWithoutSave()
            }
        } else {
            return createNewExperienceNowWithoutSave()
        }
    }

    func getCurrentFile() -> SubstancesFile? {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        guard let file = try? container.viewContext.fetch(fetchRequest).first else {return nil}
        return file

    }

    func createNewExperienceNow() -> Experience? {
        var result: Experience?
        viewContext.performAndWait {
            let experience = Experience(context: viewContext)
            let now = Date()
            experience.creationDate = now
            experience.title = now.asDateString
            try? viewContext.save()
            result = experience
        }

        return result
    }

    func createNewExperienceNowWithoutSave() -> Experience {
        let experience = Experience(context: viewContext)
        let now = Date()
        experience.creationDate = now
        experience.title = now.asDateString

        return experience
    }

    func updateIngestion(
        ingestionToUpdate: Ingestion,
        time: Date,
        route: Roa.AdministrationRoute,
        color: Ingestion.IngestionColor,
        dose: Double
    ) {
        viewContext.perform {
            ingestionToUpdate.time = time
            ingestionToUpdate.administrationRoute = route.rawValue
            ingestionToUpdate.color = color.rawValue
            ingestionToUpdate.dose = dose

            try? viewContext.save()
        }
    }

    func delete(ingestion: Ingestion) {
        viewContext.perform {
            viewContext.delete(ingestion)

            try? viewContext.save()
        }
    }

    // swiftlint:disable function_parameter_count
    func createIngestionWithoutSave(
        context: NSManagedObjectContext,
        identifier: UUID,
        addTo experience: Experience,
        substance: Substance,
        ingestionTime: Date,
        ingestionRoute: Roa.AdministrationRoute,
        color: Ingestion.IngestionColor,
        dose: Double
    ) {
        let ingestion = Ingestion(context: context)
        ingestion.identifier = identifier
        ingestion.experience = experience
        ingestion.time = ingestionTime
        ingestion.administrationRoute = ingestionRoute.rawValue
        ingestion.color = color.rawValue
        ingestion.dose = dose
        ingestion.substanceCopy = SubstanceCopy(basedOn: substance, context: context)
        substance.lastUsedDate = Date()
        substance.category?.file?.lastUsedSubstance = substance
    }

    func addInitialSubstances() {
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }

        viewContext.perform {
            do {
                let dateString = "2021/09/26 15:00"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let creationDate = formatter.date(from: dateString)!

                let substancesFile = try SubstanceDecoder.decodeSubstancesFile(from: data, with: viewContext)
                substancesFile.creationDate = creationDate
                enableUncontrolledSubstances(in: substancesFile)
                substancesFile.generalInteractionsUnwrapped.forEach({$0.isEnabled = false})

                try viewContext.save()
            } catch {
                fatalError("Failed to decode \(fileName) from bundle: \(error.localizedDescription)")
            }
        }
    }

    func toggleEye(to isOpen: Bool, modifyFile: SubstancesFile) {
        viewContext.perform {
            if isOpen {
                toggleAllOn(file: modifyFile)
            } else {
                toggleAllControlledOff(file: modifyFile)
            }
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
        makeAllFutureDownloadsEnabledByDefault(isEnabled: isOpen)
    }

    private func toggleAllOn(file: SubstancesFile) {
        file.allSubstancesUnwrapped.forEach { substance in
            substance.isEnabled = true
        }
        file.generalInteractionsUnwrapped.forEach { interaction in
            interaction.isEnabled = true
        }
    }

    private func toggleAllControlledOff(file: SubstancesFile) {
        file.allSubstancesUnwrapped.forEach { substance in
            substance.isEnabled = false
        }
        file.generalInteractionsUnwrapped.forEach { interaction in
            interaction.isEnabled = false
        }
        enableUncontrolledSubstances(in: file)
    }

    private func makeAllFutureDownloadsEnabledByDefault(isEnabled: Bool) {
        SubstanceDecoder.isDefaultEnabled = isEnabled
    }

    func enableUncontrolledSubstances(in file: SubstancesFile) {
        let namesOfUncontrolledSubstances = [
            "Caffeine",
            "Myristicin",
            "Choline bitartrate",
            "Citicoline"
        ]
        for name in namesOfUncontrolledSubstances {
            guard let foundSubstance = file.getSubstance(with: name) else {continue}
            foundSubstance.isEnabled = true
        }
    }
}
