//
//  Settings-ViewModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 28.12.22.
//

import Foundation
import CoreData

extension SettingsScreen {
    @MainActor
    class ViewModel: ObservableObject {

        @Published var isExporting = false
        @Published var journalFile = JournalFile()
        @Published var isShowingToast = false
        @Published var isShowingSuccessToast = false
        @Published var toastMessage = ""

        func exportData() {
            let experienceFetchRequest = Experience.fetchRequest()
            let allExperiences = (try? PersistenceController.shared.viewContext.fetch(experienceFetchRequest)) ?? []
            let customFetchRequest = CustomSubstance.fetchRequest()
            let allCustomSubstances = (try? PersistenceController.shared.viewContext.fetch(customFetchRequest)) ?? []
            journalFile = JournalFile(experiences: allExperiences, customSubstances: allCustomSubstances)
            isExporting = true
        }

        func importData(data: Data) {
            do {
                let file = try JSONDecoder().decode(JournalFile.self, from: data)
                let context = PersistenceController.shared.viewContext
                var companionDict: [String: SubstanceCompanion] = [:]
                for companionCodable in file.substanceCompanions {
                    let newCompanion = SubstanceCompanion(context: context)
                    newCompanion.substanceName = companionCodable.substanceName
                    newCompanion.colorAsText = companionCodable.color.rawValue
                    companionDict[companionCodable.substanceName] = newCompanion
                }
                for experienceCodable in file.experiences {
                    let newExperience = Experience(context: context)
                    newExperience.title = experienceCodable.title
                    newExperience.text = experienceCodable.text
                    newExperience.creationDate = experienceCodable.creationDate
                    newExperience.sortDate = experienceCodable.sortDate
                    newExperience.isFavorite = experienceCodable.isFavorite
                    for ingestionCodable in experienceCodable.ingestions {
                        let newIngestion = Ingestion(context: context)
                        newIngestion.substanceName = ingestionCodable.substanceName
                        newIngestion.time = ingestionCodable.time
                        newIngestion.creationDate = ingestionCodable.creationDate
                        newIngestion.administrationRoute = ingestionCodable.administrationRoute.rawValue
                        newIngestion.dose = ingestionCodable.dose ?? 0
                        newIngestion.isEstimate = ingestionCodable.isDoseAnEstimate
                        newIngestion.units = ingestionCodable.units
                        newIngestion.note = ingestionCodable.notes
                        newExperience.addToIngestions(newIngestion)
                        if let companion = companionDict[ingestionCodable.substanceName] {
                            newIngestion.substanceCompanion = companion
                        } else {
                            assertionFailure("Found no corresponding substance companion for ingestion")
                            let newCompanion = SubstanceCompanion(context: context)
                            newCompanion.substanceName = ingestionCodable.substanceName
                            newCompanion.colorAsText = (SubstanceColor.allCases.randomElement() ?? .red).rawValue
                            companionDict[ingestionCodable.substanceName] = newCompanion
                        }
                    }
                }

                for customCodable in file.customSubstances {
                    let newCustom = CustomSubstance(context: context)
                    newCustom.name = customCodable.name
                    newCustom.units = customCodable.units
                    newCustom.explanation = customCodable.description
                }
                try context.save()
                showSuccessToast(message: "Import Successful")
            } catch DecodingError.keyNotFound(let key, let context) {
                showErrorToast(message: "Import Failed")
                print("Missing key '\(key.stringValue)' not found – \(context.debugDescription)")
            } catch DecodingError.typeMismatch(_, let context) {
                showErrorToast(message: "Import Failed")
                print("Type mismatch – \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let type, let context) {
                showErrorToast(message: "Import Failed")
                print("Missing \(type) value – \(context.debugDescription)")
            } catch DecodingError.dataCorrupted(let context) {
                showErrorToast(message: "Import Failed")
                print(context.debugDescription)
            } catch {
                showErrorToast(message: "Import Failed")
                print(error.localizedDescription)
            }
        }

        func deleteEverything() {
            let context = PersistenceController.shared.viewContext
            do {
                let batchDeleteExperiences = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Experience"))
                try context.execute(batchDeleteExperiences)
                let batchDeleteIngestions = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Ingestion"))
                try context.execute(batchDeleteIngestions)
                let batchDeleteCustoms = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "CustomSubstance"))
                try context.execute(batchDeleteCustoms)
                let batchDeleteCompanions = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "SubstanceCompanion"))
                try context.execute(batchDeleteCompanions)
                showSuccessToast(message: "Delete Successful")
            } catch {
                showErrorToast(message: "Delete Failed")
            }
        }

        private func showSuccessToast(message: String) {
            toastMessage = message
            isShowingToast = true
            isShowingSuccessToast = true        }

        private func showErrorToast(message: String) {
            toastMessage = message
            isShowingToast = true
            isShowingSuccessToast = false
        }
    }
}
