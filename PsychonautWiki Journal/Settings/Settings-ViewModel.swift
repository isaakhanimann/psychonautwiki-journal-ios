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
                try PersistenceController.shared.deleteEverything()
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
                    if let location = experienceCodable.location {
                        let newLocation = ExperienceLocation(context: context)
                        newLocation.name = location.name
                        newLocation.latitude = location.latitude ?? 0
                        newLocation.longitude = location.longitude ?? 0
                        newLocation.experience = newExperience
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
                print("Data corrupted – \(context.debugDescription)")
            } catch {
                let desc = error.localizedDescription
                print("Some other error – \(desc)")
                showErrorToast(message: "Import Failed")
            }
        }

        func deleteEverything() {
            do {
                try PersistenceController.shared.deleteEverything()
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
