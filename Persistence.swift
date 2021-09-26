import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer
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

    func getCurrentFile() -> SubstancesFile? {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        guard let file = try? container.viewContext.fetch(fetchRequest).first else {return nil}
        return file

    }

    func createNewExperienceNow() -> Experience? {
        let moc = container.viewContext
        var result: Experience?
        moc.performAndWait {
            let experience = Experience(context: moc)
            let now = Date()
            experience.creationDate = now
            experience.title = now.asDateString
            try? moc.save()
            result = experience
        }

        return result
    }

    func updateIngestion(
        ingestionToUpdate: Ingestion,
        time: Date,
        route: Roa.AdministrationRoute,
        color: Ingestion.IngestionColor,
        dose: Double
    ) {
        let moc = container.viewContext
        moc.perform {
            ingestionToUpdate.time = time
            ingestionToUpdate.administrationRoute = route.rawValue
            ingestionToUpdate.color = color.rawValue
            ingestionToUpdate.dose = dose

            try? moc.save()
        }
    }

    func delete(ingestion: Ingestion) {
        let moc = container.viewContext
        moc.perform {
            moc.delete(ingestion)

            try? moc.save()
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

        let moc = container.viewContext

        moc.perform {
            do {
                let dateString = "2021/09/26 15:00"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let creationDate = formatter.date(from: dateString)!

                let substancesFile = try SubstanceDecoder.decodeSubstancesFile(from: data, with: moc)
                substancesFile.creationDate = creationDate
                enableUncontrolledSubstances(in: substancesFile)
                enableSomeInteractions(in: substancesFile)

                try moc.save()
            } catch {
                fatalError("Failed to decode \(fileName) from bundle: \(error.localizedDescription)")
            }
        }
    }

    func toggleEye(to isOpen: Bool, modifyFile: SubstancesFile) {
        let moc = container.viewContext

        moc.perform {
            if isOpen {
                toggleAllOn(file: modifyFile)
            } else {
                toggleAllControlledOff(file: modifyFile)
            }
            if moc.hasChanges {
                try? moc.save()
            }
        }
        makeAllFutureDownloadsEnabledByDefault(isEnabled: isOpen)
    }

    private func toggleAllOn(file: SubstancesFile) {
        file.allSubstancesUnwrapped.forEach { substance in
            substance.isEnabled = true
        }
    }

    private func toggleAllControlledOff(file: SubstancesFile) {
        file.allSubstancesUnwrapped.forEach { substance in
            substance.isEnabled = false
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

    private func enableSomeInteractions(in file: SubstancesFile) {
        let namesOfDefaultInteractions = [
            "Alcohol",
            "Hormonal Birth Control",
            "Antihistamine"
        ]
        for name in namesOfDefaultInteractions {
            guard let foundInteraction = file.getGeneralInteraction(with: name) else {continue}
            foundInteraction.isEnabled = true
        }
    }
}
