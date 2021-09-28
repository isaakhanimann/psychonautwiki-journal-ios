import Foundation
import CoreData
import SwiftyJSON

enum SubstanceDecoder {

    enum DecodingFileError: Error {
        case failedToDecodeOrSave
    }

    static var isDefaultEnabled = false

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
                    enableInteractions(of: substancesFile, basedOn: fileToDelete)
                    enableFavorites(of: substancesFile, basedOn: fileToDelete)
                    enableSubstances(of: substancesFile)
                    updateLastUsedSubstances(of: substancesFile, basedOn: fileToDelete)
                    moc.delete(fileToDelete)
                }
                do {
                    try moc.save()
                    didSaveSubstances = true
                } catch {
                    moc.rollback()
                    return
                }
            } catch {
                print("Failed to decode: \(error)")
                moc.rollback()
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

        let json = try JSON(data: data)
        let dataForFile = try json["data"].rawData()

        return try decoder.decode(SubstancesFile.self, from: dataForFile)
    }

    private static func updateLastUsedSubstances(
        of newSubstancesFile: SubstancesFile,
        basedOn oldSubstancesFile: SubstancesFile
    ) {
        for oldSubstance in oldSubstancesFile.allSubstancesUnwrapped {
            if let foundNewSubstance = newSubstancesFile.getSubstance(with: oldSubstance.nameUnwrapped) {
                foundNewSubstance.lastUsedDate = oldSubstance.lastUsedDate
            }
        }
    }

    private static func enableInteractions(
        of newSubstancesFile: SubstancesFile,
        basedOn oldSubstancesFile: SubstancesFile
    ) {
        newSubstancesFile.generalInteractionsUnwrapped.forEach { newInteraction in
            if let foundInteraction = oldSubstancesFile.getGeneralInteraction(
                    with: newInteraction.nameUnwrapped
            ) {
                newInteraction.isEnabled = foundInteraction.isEnabled
            } else {
                newInteraction.isEnabled = true
            }
        }
    }

    private static func enableFavorites(
        of newSubstancesFile: SubstancesFile,
        basedOn oldSubstancesFile: SubstancesFile
    ) {
        for oldSubstance in oldSubstancesFile.favoritesSorted {
            guard let foundSubstance = newSubstancesFile.getSubstance(with: oldSubstance.nameUnwrapped) else {
                continue
            }
            foundSubstance.isFavorite = true
        }
    }

    private static func enableSubstances(of newSubstancesFile: SubstancesFile) {
        newSubstancesFile.allSubstancesUnwrapped.forEach { substance in
            substance.isEnabled = isDefaultEnabled
        }

        if !isDefaultEnabled {
            PersistenceController.shared.enableUncontrolledSubstances(in: newSubstancesFile)
        }
    }
}
