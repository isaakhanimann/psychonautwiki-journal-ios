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

    func deleteAllSubstances() {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let substances = (try? viewContext.fetch(fetchRequest)) ?? []
        for substance in substances {
            viewContext.delete(substance)
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }

    func getLatestExperience() -> Experience? {
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
        guard let experiences = try? viewContext.fetch(fetchRequest) else {return nil}
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
        let data = getInitialData()
        viewContext.performAndWait {
            do {
                let substancesFile = try decodeSubstancesFile(from: data, with: viewContext)
                substancesFile.creationDate = getCreationDate()
                try viewContext.save()
            } catch {
                fatalError("Failed to decode initial substances from bundle: \(error.localizedDescription)")
            }
        }
    }

    private func getInitialData() -> Data {
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }
        return data
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
        try await viewContext.perform {
            do {
                // check if decoding will succeed
                _ = try decodeSubstancesFile(from: data, with: viewContext)
                // delete all substances, which deletes everything because all the relationships have a cascade delete
                let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
                fetchRequest.includesPropertyValues = false
                let substances = (try? viewContext.fetch(fetchRequest)) ?? []
                for substance in substances {
                    viewContext.delete(substance)
                }
                // decode substances
                _ = try decodeSubstancesFile(from: data, with: viewContext)
                try viewContext.save()
            } catch {
                viewContext.rollback()
                throw DecodingFileError.failedToDecode
            }
        }
    }

    func cleanupCoreData() {
        convertSubstanceNamesOfIngestions()
        deleteAllOldStuff()
        addInitialSubstances()
        convertUnitsOfIngestions()
        deleteAllSubstanceCopies()
    }

    private func convertSubstanceNamesOfIngestions() {
        viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
            let ingestions = (try? viewContext.fetch(fetchRequest)) ?? []
            for ingestion in ingestions {
                ingestion.substanceName = ingestion.substanceCopy?.nameUnwrapped
            }
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }

    private func deleteAllOldStuff() {
        viewContext.performAndWait {
            deleteFiles()
            deleteSubstances()
            deleteRoas()
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }

    private func deleteFiles() {
        let fetchRequest: NSFetchRequest<SubstancesFile> = SubstancesFile.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let files = (try? viewContext.fetch(fetchRequest)) ?? []
        for file in files {
            viewContext.delete(file)
        }
    }

    private func deleteSubstances() {
        let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let subs = (try? viewContext.fetch(fetchRequest)) ?? []
        for sub in subs {
            viewContext.delete(sub)
        }
    }

    private func deleteRoas() {
        let fetchRequest: NSFetchRequest<Roa> = Roa.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let roas = (try? viewContext.fetch(fetchRequest)) ?? []
        for roa in roas {
            viewContext.delete(roa)
        }
    }

    private func convertUnitsOfIngestions() {
        viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<Ingestion> = Ingestion.fetchRequest()
            let ingestions = (try? viewContext.fetch(fetchRequest)) ?? []
            for ingestion in ingestions {
                let substance = getSubstance(with: ingestion.substanceNameUnwrapped)
                let dose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
                ingestion.units = dose?.units
            }
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }

    private func deleteAllSubstanceCopies() {
        viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<SubstanceCopy> = SubstanceCopy.fetchRequest()
            fetchRequest.includesPropertyValues = false
            let substanceCopies = (try? viewContext.fetch(fetchRequest)) ?? []
            for substanceCopy in substanceCopies {
                viewContext.delete(substanceCopy)
            }
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }

    func getSubstance(with name: String) -> Substance? {
        let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        return try? viewContext.fetch(fetchRequest).first
    }

}
