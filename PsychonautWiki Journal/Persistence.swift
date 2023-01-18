// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()
    let container: NSPersistentContainer
    static let needsToSeeWelcomeKey = "needsToSeeWelcome"
    static let isEyeOpenKey1 = "isEyeOpen"
    static let isEyeOpenKey2 = "isEyeOpen2"
    static let hasInitialSubstancesOfCurrentVersion = "hasInitialSubstancesOfVersion1.1"
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    private static let modelName = "Main"

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: PersistenceController.modelName)
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

    enum DeleteError: Error {
        case noUrlFound
    }

    func deleteEverything() throws {
        let experienceDeleteRequest = Experience.fetchRequest()
        experienceDeleteRequest.includesPropertyValues = false
        let experiences = try viewContext.fetch(experienceDeleteRequest)
        for exp in experiences {
            viewContext.delete(exp)
        }
        let ingestionDeleteRequest = Ingestion.fetchRequest()
        ingestionDeleteRequest.includesPropertyValues = false
        let ingestions = try viewContext.fetch(ingestionDeleteRequest)
        for ing in ingestions {
            viewContext.delete(ing)
        }
        let customDeleteRequest = CustomSubstance.fetchRequest()
        customDeleteRequest.includesPropertyValues = false
        let customs = try viewContext.fetch(customDeleteRequest)
        for cust in customs {
            viewContext.delete(cust)
        }
        let companionDeleteRequest = SubstanceCompanion.fetchRequest()
        companionDeleteRequest.includesPropertyValues = false
        let companions = try viewContext.fetch(companionDeleteRequest)
        for com in companions {
            viewContext.delete(com)
        }
        try viewContext.save()
    }

    func migrate() {
        viewContext.performAndWait {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            let allIngestions = (try? viewContext.fetch(ingestionFetchRequest)) ?? []
            var companionsDict: [String: SubstanceCompanion] = [:]
            for ingestion in allIngestions {
                guard let name = ingestion.substanceName else {continue}
                guard let colorUnwrap = ingestion.color else {continue}
                if let companion = companionsDict[name] {
                    ingestion.substanceCompanion = companion
                } else {
                    let companion = SubstanceCompanion(context: viewContext)
                    companion.substanceName = name
                    companion.colorAsText = colorUnwrap
                    ingestion.substanceCompanion = companion
                    companionsDict[name] = companion
                }
            }
            let experienceFetchRequest = Experience.fetchRequest()
            let allExperiences = (try? viewContext.fetch(experienceFetchRequest)) ?? []
            for experience in allExperiences {
                experience.sortDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.creationDate
            }
            try? viewContext.save()
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

    func getLatestExperience() -> Experience? {
        let fetchRequest: NSFetchRequest<Experience> = Experience.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false) ]
        fetchRequest.fetchLimit = 10
        let experiences = (try? viewContext.fetch(fetchRequest)) ?? []
        return experiences.sorted().first
    }

    func getRecentIngestions() -> [Ingestion] {
        let fetchRequest = Ingestion.fetchRequest()
        let twoDaysAgo = Date().addingTimeInterval(-2*24*60*60)
        fetchRequest.predicate = NSPredicate(format: "time > %@", twoDaysAgo as NSDate)
        return (try? viewContext.fetch(fetchRequest)) ?? []
    }

}
