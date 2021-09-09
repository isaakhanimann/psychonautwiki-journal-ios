import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer
    static let hasBeenSetupBeforeKey = "hasBeenSetupBefore"

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

    func getLatestExperience() -> Experience? {
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
        guard let experiences = try? container.viewContext.fetch(fetchRequest) else {return nil}
        return experiences.first
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

    // swiftlint:disable function_parameter_count
    func createIngestion(
        identifier: UUID,
        addTo experience: Experience,
        substance: Substance,
        ingestionTime: Date,
        ingestionRoute: Roa.AdministrationRoute,
        color: Ingestion.IngestionColor,
        dose: Double
    ) {
        let moc = container.viewContext
        moc.performAndWait {
            let ingestion = Ingestion(context: moc)
            ingestion.identifier = identifier
            ingestion.experience = experience
            ingestion.time = ingestionTime
            ingestion.administrationRoute = ingestionRoute.rawValue
            ingestion.color = color.rawValue
            ingestion.dose = dose
            ingestion.substanceCopy = SubstanceCopy(basedOn: substance, context: moc)
            substance.lastUsedDate = Date()
            substance.category!.file!.lastUsedSubstance = substance

            try? moc.save()
        }
    }
}
