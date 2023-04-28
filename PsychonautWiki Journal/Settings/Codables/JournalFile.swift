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

import SwiftUI
import UniformTypeIdentifiers

struct JournalFile: FileDocument, Codable {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]
    var experiences: [ExperienceCodable]
    var substanceCompanions: [CompanionCodable]
    var customSubstances: [CustomSubstanceCodable]

    init(experiences: [Experience] = [], customSubstances: [CustomSubstance] = []) {
        var experiencesToStore: [ExperienceCodable] = []
        var companionsToStore: [CompanionCodable] = []
        for experience in experiences {
            var ingestionsInExperience: [IngestionCodable] = []
            for ingestion in experience.sortedIngestionsUnwrapped {
                ingestionsInExperience.append(
                    IngestionCodable(
                        substanceName: ingestion.substanceNameUnwrapped,
                        time: ingestion.timeUnwrapped,
                        creationDate: ingestion.creationDate,
                        administrationRoute: ingestion.administrationRouteUnwrapped,
                        dose: ingestion.doseUnwrapped,
                        isDoseAnEstimate: ingestion.isEstimate,
                        units: ingestion.unitsUnwrapped,
                        notes: ingestion.noteUnwrapped,
                        stomachFullness: ingestion.stomachFullnessUnwrapped
                    )
                )
                let doesCompanionAlreadyExist = companionsToStore.contains { com in
                    com.substanceName == ingestion.substanceNameUnwrapped
                }
                if !doesCompanionAlreadyExist {
                    companionsToStore.append(
                        CompanionCodable(
                            substanceName: ingestion.substanceNameUnwrapped,
                            color: ingestion.substanceColor
                        )
                    )
                }
            }
            let ratings = experience.ratingsWithTimeSorted.map { shulginRating in
                RatingCodable(
                    creationDate: shulginRating.creationDateUnwrapped,
                    time: shulginRating.timeUnwrapped,
                    option: shulginRating.optionUnwrapped
                )
            }
            experiencesToStore.append(
                ExperienceCodable(
                    title: experience.titleUnwrapped,
                    text: experience.textUnwrapped,
                    creationDate: experience.creationDateUnwrapped,
                    sortDate: experience.sortDate,
                    isFavorite: experience.isFavorite,
                    ingestions: ingestionsInExperience,
                    ratings: ratings,
                    experienceLocation: experience.location
                )
            )

        }
        self.experiences = experiencesToStore
        self.substanceCompanions = companionsToStore
        self.customSubstances = customSubstances.map { cust in
            CustomSubstanceCodable(
                name: cust.nameUnwrapped,
                units: cust.unitsUnwrapped,
                description: cust.explanationUnwrapped
            )
        }
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            let decoder = JSONDecoder()
            self = try decoder.decode(Self.self, from: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}


