import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()
    let container: NSPersistentContainer
    static let comesFromVersion10Key = "hasBeenSetupBefore"
    static let needsToSeeWelcomeKey = "needsToSeeWelcome"
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

    func getLatestExperience() -> Experience? {
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
        fetchRequest.fetchLimit = 10
        let experiences = (try? viewContext.fetch(fetchRequest)) ?? []
        return experiences.sorted().first
    }

    enum DecodingFileError: Error {
        case failedToDecode
    }

    func getRecentIngestions() -> [Ingestion] {
        let fetchRequest = Ingestion.fetchRequest()
        let twoDaysAgo = Date().addingTimeInterval(-2*24*60*60)
        fetchRequest.predicate = NSPredicate(format: "time > %@", twoDaysAgo as NSDate)
        return (try? viewContext.fetch(fetchRequest)) ?? []
    }

}
