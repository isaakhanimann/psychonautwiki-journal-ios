import Foundation
import CoreData

enum SubstanceDecoder {

    enum DecodingFileError: Error {
        case failedToDecodeOrSave
    }

    static func decodeAndSaveFile(
        from data: Data) throws {
        let moc = PersistenceController.shared.container.viewContext
        var didSaveSubstances = false

        moc.performAndWait {
            guard let substancesFile = try? decodeSubstancesFile(from: data, with: moc) else {
                return
            }
            substancesFile.creationDate = Date()

            buildInteractionRelationships(for: substancesFile)

            do {
                try moc.save()
                didSaveSubstances = true
            } catch {
                return
            }
        }

        if !didSaveSubstances {
            throw DecodingFileError.failedToDecodeOrSave
        }
    }

    // swiftlint:disable cyclomatic_complexity
    static func buildInteractionRelationships(for decodedFile: SubstancesFile) {
        for substance in decodedFile.allSubstancesUnwrapped {

            for unsafeSubstanceName in substance.unsafeSubstanceInteractionsDecoded {
                if let foundSubstance = decodedFile.getSubstance(with: unsafeSubstanceName) {
                    substance.addToUnsafeSubstanceInteractions(foundSubstance)
                } else {
                    assertionFailure("Failed to find \(unsafeSubstanceName)")
                }
            }

            for unsafeCategoryName in substance.unsafeCategoryInteractionsDecoded {
                if let foundCategory = decodedFile.getCategory(with: unsafeCategoryName) {
                    substance.addToUnsafeCategoryInteractions(foundCategory)
                } else {
                    assertionFailure("Failed to find \(unsafeCategoryName)")
                }
            }

            for unsafeGeneralInteractionName in substance.unsafeGeneralInteractionsDecoded {
                if let foundGeneralInteraction = decodedFile.getGeneralInteraction(with: unsafeGeneralInteractionName) {
                    substance.addToUnsafeGeneralInteractions(foundGeneralInteraction)
                } else {
                    assertionFailure("Failed to find \(unsafeGeneralInteractionName)")
                }
            }

            for dangerousSubstanceName in substance.dangerousSubstanceInteractionsDecoded {
                if let foundSubstance = decodedFile.getSubstance(with: dangerousSubstanceName) {
                    substance.addToDangerousSubstanceInteractions(foundSubstance)
                } else {
                    assertionFailure("Failed to find \(dangerousSubstanceName)")
                }
            }

            for dangerousCategoryName in substance.dangerousCategoryInteractionsDecoded {
                if let foundCategory = decodedFile.getCategory(with: dangerousCategoryName) {
                    substance.addToDangerousCategoryInteractions(foundCategory)
                } else {
                    assertionFailure("Failed to find \(dangerousCategoryName)")
                }
            }

            for dangerousGeneralInteractionName in substance.dangerousGeneralInteractionsDecoded {
                if let foundGeneralInteraction = decodedFile.getGeneralInteraction(
                    with: dangerousGeneralInteractionName
                ) {
                    substance.addToDangerousGeneralInteractions(foundGeneralInteraction)
                } else {
                    assertionFailure("Failed to find \(dangerousGeneralInteractionName)")
                }
            }
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
