import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()
    let container: NSPersistentContainer
    static let comesFromVersion10Key = "hasBeenSetupBefore"
    static let hasSeenWelcomeKey = "hasSeenWelcome"
    static let isEyeOpenKey = "isEyeOpen"
    static let hasInitialSubstancesOfCurrentVersion = "hasInitialSubstancesOfVersion1.1"
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Main")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveViewContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                assertionFailure("Failed to save viewContext: \(error)")
            }
        }
    }

    func deleteAllSubstancesWithSave() {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.performAndWait {
            deleteAllSubstancesWithoutSave(context: backgroundContext)
            if backgroundContext.hasChanges {
                try? backgroundContext.save()
            }
        }
    }

    func deleteAllSubstancesWithoutSave(context: NSManagedObjectContext) {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let substances = (try? context.fetch(fetchRequest)) ?? []
        for substance in substances {
            context.delete(substance)
        }
    }

    func resetAllSubstancesToInitialAndSave() async {
        let backgroundContext = container.newBackgroundContext()
        await backgroundContext.perform {
            deleteAllSubstancesWithoutSave(context: backgroundContext)
            let data = getInitialData()
            do {
                let substancesFile = try decodeSubstancesFile(from: data, with: backgroundContext)
                substancesFile.creationDate = getCreationDate()
                try backgroundContext.save()
            } catch {
                backgroundContext.rollback()
            }
        }
    }

    func getLatestExperience() -> Experience? {
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
        fetchRequest.fetchLimit = 10
        let experiences = (try? viewContext.fetch(fetchRequest)) ?? []
        return experiences.sorted().first
    }

    func addInitialSubstances(context: NSManagedObjectContext? = nil) {
        let data = getInitialData()
        let backgroundContext = context ?? container.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                let substancesFile = try decodeSubstancesFile(from: data, with: backgroundContext)
                substancesFile.creationDate = getCreationDate()
                try backgroundContext.save()
            } catch {
                fatalError("Failed to decode initial substances from bundle: \(error.localizedDescription)")
            }
        }
    }

    private func getCreationDate() -> Date {
        let dateString = "2022/02/25 16:54"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let creationDate = formatter.date(from: dateString)!
        return creationDate
    }

    enum DecodingFileError: Error {
        case failedToDecode
    }

    func decodeAndSaveFile(from data: Data) async throws {
        let backgroundContext = container.newBackgroundContext()
        try await backgroundContext.perform {
            do {
                // check if decoding will succeed
                _ = try decodeSubstancesFile(from: data, with: backgroundContext)
                // delete all substances, which deletes everything because all the relationships have a cascade delete
                let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
                fetchRequest.includesPropertyValues = false
                let substances = (try? backgroundContext.fetch(fetchRequest)) ?? []
                for substance in substances {
                    backgroundContext.delete(substance)
                }
                let file = try decodeSubstancesFile(from: data, with: backgroundContext)
                file.creationDate = Date()
                try backgroundContext.save()
            } catch {
                backgroundContext.rollback()
                throw DecodingFileError.failedToDecode
            }
        }
    }

    func cleanupCoreData() {
        let backgroundContext = container.newBackgroundContext()
        convertSubstanceNamesOfIngestions(context: backgroundContext)
        deleteAllOldStuff(context: backgroundContext)
        addInitialSubstances(context: backgroundContext)
        convertUnitsOfIngestions(context: backgroundContext)
        deleteAllSubstanceCopies(context: backgroundContext)
    }

    private func convertSubstanceNamesOfIngestions(context: NSManagedObjectContext) {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
            let ingestions = (try? context.fetch(fetchRequest)) ?? []
            for ingestion in ingestions {
                ingestion.substanceName = ingestion.substanceCopy?.nameUnwrapped
            }
            if context.hasChanges {
                try? context.save()
            }
        }
    }

    private func deleteAllOldStuff(context: NSManagedObjectContext) {
        context.performAndWait {
            deleteFiles(context: context)
            deleteSubstances(context: context)
            deleteRoas(context: context)
            if context.hasChanges {
                try? context.save()
            }
        }
    }

    private func deleteFiles(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let files = (try? context.fetch(fetchRequest)) ?? []
        for file in files {
            context.delete(file)
        }
    }

    private func deleteSubstances(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let subs = (try? context.fetch(fetchRequest)) ?? []
        for sub in subs {
            context.delete(sub)
        }
    }

    private func deleteRoas(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Roa> = Roa.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let roas = (try? context.fetch(fetchRequest)) ?? []
        for roa in roas {
            context.delete(roa)
        }
    }

    private func convertUnitsOfIngestions(context: NSManagedObjectContext) {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
            let ingestions = (try? context.fetch(fetchRequest)) ?? []
            for ingestion in ingestions {
                let substance = getSubstance(with: ingestion.substanceNameUnwrapped)
                let dose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
                ingestion.units = dose?.units
            }
            if context.hasChanges {
                try? context.save()
            }
        }
    }

    private func deleteAllSubstanceCopies(context: NSManagedObjectContext) {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<SubstanceCopy> = SubstanceCopy.fetchRequest()
            fetchRequest.includesPropertyValues = false
            let substanceCopies = (try? context.fetch(fetchRequest)) ?? []
            for substanceCopy in substanceCopies {
                context.delete(substanceCopy)
            }
            if context.hasChanges {
                try? context.save()
            }
        }
    }

    func getSubstance(with name: String) -> Substance? {
        let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        return try? viewContext.fetch(fetchRequest).first
    }

    func getRecentIngestions() -> [Ingestion] {
        let fetchRequest = Ingestion.fetchRequest()
        let twoDaysAgo = Date().addingTimeInterval(-2*24*60*60)
        fetchRequest.predicate = NSPredicate(format: "time > %@", twoDaysAgo as NSDate)
        return (try? viewContext.fetch(fetchRequest)) ?? []
    }

}
