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
    var customUnits: [CustomUnitCodable]

    // swiftlint:disable function_body_length
    init(
        experiences: [Experience],
        customSubstances: [CustomSubstance],
        customUnits: [CustomUnit]
    ) {
        var experiencesToStore: [ExperienceCodable] = []
        var companionsToStore: [CompanionCodable] = []
        for experience in experiences {
            var ingestionsInExperience: [IngestionCodable] = []
            for ingestion in experience.ingestionsSorted {
                ingestionsInExperience.append(
                    IngestionCodable(
                        substanceName: ingestion.substanceNameUnwrapped,
                        time: ingestion.timeUnwrapped,
                        endTime: ingestion.endTime,
                        creationDate: ingestion.creationDate,
                        administrationRoute: ingestion.administrationRouteUnwrapped,
                        dose: ingestion.doseUnwrapped,
                        estimatedDoseStandardDeviation: ingestion.estimatedDoseStandardDeviationUnwrapped,
                        isDoseAnEstimate: ingestion.isEstimate,
                        units: ingestion.unitsUnwrapped,
                        notes: ingestion.noteUnwrapped,
                        stomachFullness: ingestion.stomachFullnessUnwrapped,
                        consumerName: ingestion.consumerName,
                        customUnitId: ingestion.customUnit?.idForAndroid
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
            let ratings = experience.ratingsUnwrapped.map { shulginRating in
                RatingCodable(
                    creationDate: shulginRating.creationDateUnwrapped,
                    time: shulginRating.time,
                    option: shulginRating.optionUnwrapped
                )
            }
            let timedNotes = experience.timedNotesSorted.map { timedNote in
                TimedNoteCodable(
                    creationDate: timedNote.creationDateUnwrapped,
                    time: timedNote.timeUnwrapped,
                    note: timedNote.noteUnwrapped,
                    color: timedNote.color,
                    isPartOfTimeline: timedNote.isPartOfTimeline
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
                    timedNotes: timedNotes,
                    experienceLocation: experience.location
                )
            )
        }
        self.experiences = experiencesToStore
        substanceCompanions = companionsToStore
        self.customSubstances = customSubstances.map { cust in
            CustomSubstanceCodable(
                name: cust.nameUnwrapped,
                units: cust.unitsUnwrapped,
                description: cust.explanationUnwrapped
            )
        }
        self.customUnits = customUnits.map { customUnit in
            CustomUnitCodable(
                id: customUnit.idForAndroid,
                substanceName: customUnit.substanceNameUnwrapped,
                name: customUnit.nameUnwrapped,
                creationDate: customUnit.creationDateUnwrapped,
                administrationRoute: customUnit.administrationRouteUnwrapped,
                dose: customUnit.doseUnwrapped,
                estimatedDoseStandardDeviation: customUnit.estimatedDoseStandardDeviationUnwrapped,
                isEstimate: customUnit.isEstimate,
                isArchived: customUnit.isArchived,
                unit: customUnit.unitUnwrapped,
                unitPlural: customUnit.unitPlural,
                originalUnit: customUnit.originalUnitUnwrapped,
                note: customUnit.noteUnwrapped)
        }
    }
    // swiftlint:enable function_body_length

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            let decoder = JSONDecoder()
            self = try decoder.decode(Self.self, from: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return FileWrapper(regularFileWithContents: data)
    }



    enum CodingKeys: String, CodingKey {
        case experiences
        case substanceCompanions
        case customSubstances
        case customUnits
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        experiences = try values.decodeIfPresent([ExperienceCodable].self, forKey: .experiences) ?? []
        substanceCompanions = try values.decodeIfPresent([CompanionCodable].self, forKey: .substanceCompanions) ?? []
        customSubstances = try values.decodeIfPresent([CustomSubstanceCodable].self, forKey: .customSubstances) ?? []
        customUnits = try values.decodeIfPresent([CustomUnitCodable].self, forKey: .customUnits) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(experiences, forKey: .experiences)
        try container.encode(substanceCompanions, forKey: .substanceCompanions)
        try container.encode(customSubstances, forKey: .customSubstances)
        try container.encode(customUnits, forKey: .customUnits)
    }
}
