import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    let container: NSPersistentCloudKitContainer
    static let appGroupName = "group.substanceShare"
    static let isThereANewFileKey = "isThereANewFile"
    static let hasBeenSetupBeforeKey = "hasBeenSetupBefore"
    static let hasAcceptedImportKey = "hasAcceptedImport"

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")

        guard let fileContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: PersistenceController.appGroupName
        ) else {
            fatalError("Shared file container could not be created.")
        }
        let sharedURL = fileContainer.appendingPathComponent("Default.sqlite")
        let sharedStoreDescription = NSPersistentStoreDescription(url: sharedURL)
        sharedStoreDescription.configuration = "Default"

        if inMemory {
            sharedStoreDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        container.persistentStoreDescriptions = [sharedStoreDescription]
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func createPreviewHelper() -> PreviewHelper {
        PreviewHelper(context: container.viewContext)
    }
}
