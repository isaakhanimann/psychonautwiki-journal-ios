import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentContainer
    // use viewContext to view objects and edit visible objects
    let viewContext: NSManagedObjectContext
    // use backgroundContext to parse new file and delete old one
    private let backgroundContext: NSManagedObjectContext
    static let comesFromVersion10Key = "hasBeenSetupBefore"
    static let hasSeenWelcomeKey = "hasSeenWelcome"
    static let isEyeOpenKey = "isEyeOpen"
    static let hasInitialSubstancesKey = "hasInitialSubstances"

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
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext = container.newBackgroundContext()
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
        guard let file = try? viewContext.fetch(fetchRequest).first else {return nil}
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

                let substancesFile = try decodeSubstancesFile(from: data, with: viewContext)
                substancesFile.creationDate = creationDate

                try viewContext.save()
            } catch {
                fatalError("Failed to decode \(fileName) from bundle: \(error.localizedDescription)")
            }
        }
    }

    enum DecodingFileError: Error {
        case failedToSave
    }

    func decodeAndSaveFile(from data: Data) throws {
        var didSaveSubstances = false
        backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
            let earlierFileToDelete = try? backgroundContext.fetch(fetchRequest).first
            do {
                let substancesFile = try decodeSubstancesFile(from: data, with: backgroundContext)
                substancesFile.creationDate = Date()
                if let fileToDelete = earlierFileToDelete {
                    backgroundContext.delete(fileToDelete)
                }
                do {
                    try backgroundContext.save()
                    didSaveSubstances = true
                } catch {
                    backgroundContext.rollback()
                    return
                }
            } catch {
                backgroundContext.rollback()
            }
        }
        if !didSaveSubstances {
            throw DecodingFileError.failedToSave
        }
    }

    func cleanupCoreData() {
        backgroundContext.performAndWait {
            convertSubstanceNamesOfIngestions()
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
        PersistenceController.shared.addInitialSubstances()
        backgroundContext.performAndWait {
            convertUnitsOfIngestions()
            deleteAllSubstanceCopies()
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    private func convertSubstanceNamesOfIngestions() {
        let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
        let ingestions = (try? backgroundContext.fetch(fetchRequest)) ?? []
        for ingestion in ingestions {
            ingestion.substanceName = ingestion.substanceCopy?.nameUnwrapped
        }
    }

    private func convertUnitsOfIngestions() {
        let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
        let ingestions = (try? backgroundContext.fetch(fetchRequest)) ?? []
        for ingestion in ingestions {
            let substance = getSubstance(with: ingestion.substanceNameUnwrapped)
            let dose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
            ingestion.units = dose?.units
        }
    }

    private func deleteAllSubstanceCopies() {
        let fetchRequest: NSFetchRequest<SubstanceCopy> = SubstanceCopy.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let substanceCopies = (try? backgroundContext.fetch(fetchRequest)) ?? []
        for substanceCopy in substanceCopies {
            backgroundContext.delete(substanceCopy)
        }
    }

    func getSubstance(with name: String) -> Substance? {
        let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
        let pred = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = pred
        return try? viewContext.fetch(fetchRequest).first
    }

}
