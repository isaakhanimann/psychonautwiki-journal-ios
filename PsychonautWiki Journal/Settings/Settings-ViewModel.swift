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
import Foundation

extension SettingsScreen {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var isExporting = false
        @Published var journalFile = JournalFile(experiences: [], customSubstances: [], customUnits: [])
        @Published var isShowingToast = false
        @Published var isShowingSuccessToast = false
        @Published var toastMessage = ""

        func exportData() {
            let experienceFetchRequest = Experience.fetchRequest()
            let allExperiences = (try? PersistenceController.shared.viewContext.fetch(experienceFetchRequest)) ?? []
            let customFetchRequest = CustomSubstance.fetchRequest()
            let allCustomSubstances = (try? PersistenceController.shared.viewContext.fetch(customFetchRequest)) ?? []
            let customUnitsFetchRequest = CustomUnit.fetchRequest()
            let allCustomUnits = (try? PersistenceController.shared.viewContext.fetch(customUnitsFetchRequest)) ?? []
            journalFile = JournalFile(
                experiences: allExperiences,
                customSubstances: allCustomSubstances,
                customUnits: allCustomUnits)
            isExporting = true
        }

        // swiftlint:disable cyclomatic_complexity function_body_length
        func importData(data: Data) {
            do {
                let file = try JSONDecoder().decode(JournalFile.self, from: data)
                try PersistenceController.shared.deleteEverything()
                let context = PersistenceController.shared.viewContext
                // companions
                var companionDict: [String: SubstanceCompanion] = [:]
                for companionCodable in file.substanceCompanions {
                    let newCompanion = SubstanceCompanion(context: context)
                    newCompanion.substanceName = companionCodable.substanceName
                    newCompanion.colorAsText = companionCodable.color.rawValue
                    companionDict[companionCodable.substanceName] = newCompanion
                }
                // custom units
                var unitsDict: [Int32: CustomUnit] = [:]
                for customUnitCodable in file.customUnits {
                    let newUnit = CustomUnit(context: context)
                    newUnit.substanceName = customUnitCodable.substanceName
                    newUnit.name = customUnitCodable.name
                    newUnit.creationDate = customUnitCodable.creationDate
                    newUnit.administrationRoute = customUnitCodable.administrationRoute.rawValue
                    newUnit.dose = customUnitCodable.dose ?? 0
                    newUnit.estimatedDoseStandardDeviation = customUnitCodable.estimatedDoseStandardDeviation ?? 0
                    newUnit.isEstimate = customUnitCodable.isEstimate
                    newUnit.isArchived = customUnitCodable.isArchived
                    newUnit.unit = customUnitCodable.unit
                    newUnit.unitPlural = customUnitCodable.unitPlural
                    newUnit.originalUnit = customUnitCodable.originalUnit
                    newUnit.note = customUnitCodable.note
                    newUnit.idForAndroid = customUnitCodable.id
                    unitsDict[customUnitCodable.id] = newUnit
                }
                // experience
                for experienceCodable in file.experiences {
                    let newExperience = Experience(context: context)
                    newExperience.title = experienceCodable.title
                    newExperience.text = experienceCodable.text
                    newExperience.creationDate = experienceCodable.creationDate
                    newExperience.sortDate = experienceCodable.sortDate
                    newExperience.isFavorite = experienceCodable.isFavorite
                    // ingestion
                    for ingestionCodable in experienceCodable.ingestions {
                        let newIngestion = Ingestion(context: context)
                        newIngestion.substanceName = ingestionCodable.substanceName
                        newIngestion.time = ingestionCodable.time
                        newIngestion.endTime = ingestionCodable.endTime
                        newIngestion.creationDate = ingestionCodable.creationDate
                        newIngestion.administrationRoute = ingestionCodable.administrationRoute.rawValue
                        newIngestion.dose = ingestionCodable.dose ?? 0
                        newIngestion.estimatedDoseStandardDeviation = ingestionCodable.estimatedDoseStandardDeviation ?? 0
                        newIngestion.isEstimate = ingestionCodable.isDoseAnEstimate
                        newIngestion.units = ingestionCodable.units
                        newIngestion.note = ingestionCodable.notes
                        newIngestion.stomachFullness = ingestionCodable.stomachFullness?.rawValue
                        newIngestion.consumerName = ingestionCodable.consumerName
                        newExperience.addToIngestions(newIngestion)
                        // add companion to ingestion
                        if let companion = companionDict[ingestionCodable.substanceName] {
                            newIngestion.substanceCompanion = companion
                        } else {
                            assertionFailure("Found no corresponding substance companion for ingestion")
                            let newCompanion = SubstanceCompanion(context: context)
                            newCompanion.substanceName = ingestionCodable.substanceName
                            newCompanion.colorAsText = (SubstanceColor.allCases.randomElement() ?? .red).rawValue
                            companionDict[ingestionCodable.substanceName] = newCompanion
                        }
                        // add custom unit to ingestion
                        if let customUnitId = ingestionCodable.customUnitId {
                            newIngestion.customUnit = unitsDict[customUnitId]
                        }
                    }
                    // ratings
                    for ratingCodable in experienceCodable.ratings {
                        let newRating = ShulginRating(context: context)
                        newRating.creationDate = ratingCodable.creationDate
                        newRating.time = ratingCodable.time
                        newRating.option = ratingCodable.option.rawValue
                        newRating.experience = newExperience
                    }
                    // timed notes
                    for timedNoteCodable in experienceCodable.timedNotes {
                        let newTimedNote = TimedNote(context: context)
                        newTimedNote.creationDate = timedNoteCodable.creationDate
                        newTimedNote.time = timedNoteCodable.time
                        newTimedNote.note = timedNoteCodable.note
                        newTimedNote.colorAsText = timedNoteCodable.color.rawValue
                        newTimedNote.isPartOfTimeline = timedNoteCodable.isPartOfTimeline
                        newTimedNote.experience = newExperience
                    }
                    // location
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
            } catch let DecodingError.keyNotFound(key, context) {
                showErrorToast(message: "Import Failed")
                print("Missing key '\(key.stringValue)' not found – \(context.debugDescription) at \(context.codingPath)")
            } catch let DecodingError.typeMismatch(_, context) {
                showErrorToast(message: "Import Failed")
                print("Type mismatch – \(context.debugDescription)")
            } catch let DecodingError.valueNotFound(type, context) {
                let error = "Missing \(type) value – \(context.debugDescription) - codingPath: \(context.codingPath)"
                print(error)
                showErrorToast(message: "Import Failed")
            } catch let DecodingError.dataCorrupted(context) {
                showErrorToast(message: "Import Failed")
                print("Data corrupted – \(context.debugDescription)")
            } catch {
                let desc = error.localizedDescription
                print("Some other error – \(desc)")
                showErrorToast(message: "Import Failed")
            }
        }
        // swiftlint:enable cyclomatic_complexity function_body_length

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
            isShowingSuccessToast = true
        }

        private func showErrorToast(message: String) {
            toastMessage = message
            isShowingToast = true
            isShowingSuccessToast = false
        }
    }
}
