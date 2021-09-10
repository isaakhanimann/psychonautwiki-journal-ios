import Foundation
import CoreData
import SwiftyJSON

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
                    enableInteractions(of: substancesFile, basedOn: fileToDelete)
                    enableFavorites(of: substancesFile, basedOn: fileToDelete)
                    enableSubstances(of: substancesFile, basedOn: fileToDelete)
                    updateLastUsedSubstances(of: substancesFile, basedOn: fileToDelete)
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
        let oldEnabledInteractions = oldSubstancesFile.generalInteractionsUnwrapped.filter { interaction in
            interaction.isEnabled
        }
        for oldInteraction in oldEnabledInteractions {
            guard let foundInteraction = newSubstancesFile.getGeneralInteraction(
                    with: oldInteraction.nameUnwrapped
            ) else {
                continue
            }
            foundInteraction.isEnabled = true
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

    private static func enableSubstances(
        of newSubstancesFile: SubstancesFile,
        basedOn oldSubstancesFile: SubstancesFile
    ) {
        for oldSubstance in oldSubstancesFile.allEnabledSubstancesUnwrapped {
            guard let foundSubstance = newSubstancesFile.getSubstance(with: oldSubstance.nameUnwrapped) else {
                continue
            }
            foundSubstance.isEnabled = true
        }
    }
}
