import Foundation
import CoreData

enum SubstanceDecoder {

    enum DecodingFileError: Error {
        case failedToDecodeOrSave
    }

    static func decodeAndSaveFile(
        from data: Data,
        creationDate: Date,
        earlierFileToDelete: SubstancesFile?
    ) throws {
        let moc = PersistenceController.shared.container.viewContext
        var didSaveSubstances = false

        moc.performAndWait {
            do {
                let substancesFile = try decodeSubstancesFile(from: data, with: moc)
                substancesFile.creationDate = creationDate
                if let fileToDelete = earlierFileToDelete {
                    moc.delete(fileToDelete)
                }
                do {
                    try moc.save()
                    didSaveSubstances = true
                } catch {
                    moc.undo()
                    return
                }
            } catch {
                print("Failed to decode: \(error)")
                moc.undo()
            }
        }

        if !didSaveSubstances {
            throw DecodingFileError.failedToDecodeOrSave
        }
    }

    static func decodeSubstancesFile(
        from data: Data,
        with context: NSManagedObjectContext
    ) throws -> SubstancesFile {

        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
        decoder.dateDecodingStrategy = .deferredToDate
        decoder.keyDecodingStrategy = .useDefaultKeys

        return try decoder.decode(SubstancesFile.self, from: data)
    }
}
