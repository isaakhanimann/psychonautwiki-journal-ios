//
//  JournalFile.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 28.12.22.
//

import SwiftUI
import UniformTypeIdentifiers


struct JournalFile: FileDocument, Codable {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]
    var ingestions: [IngestionCodable]
    var experiences: [ExperienceCodable]
    var substanceCompanions: [CompanionCodable]
    var customSubstances: [CustomSubstanceCodable]

    init(experiences: [Experience] = [], customSubstances: [CustomSubstance] = []) {
        var ingestionsToStore: [IngestionCodable] = []
        var experiencesToStore: [ExperienceCodable] = []
        var companionsToStore: [CompanionCodable] = []
        var currentIngestionID = 1
        for experienceIndex in 0..<experiences.count {
            let experience = experiences[experienceIndex]
            let experienceID = experienceIndex + 1
            experiencesToStore.append(
                ExperienceCodable(
                    id: experienceID,
                    title: experience.titleUnwrapped,
                    text: experience.textUnwrapped,
                    creationDate: experience.creationDateUnwrapped,
                    sortDate: experience.sortDate
                )
            )
            for ingestion in experience.sortedIngestionsUnwrapped {
                ingestionsToStore.append(
                    IngestionCodable(
                        id: currentIngestionID,
                        substanceName: ingestion.substanceNameUnwrapped,
                        time: ingestion.timeUnwrapped,
                        creationDate: ingestion.creationDate,
                        administrationRoute: ingestion.administrationRouteUnwrapped,
                        dose: ingestion.doseUnwrapped,
                        isDoseAnEstimate: ingestion.isEstimate,
                        units: ingestion.unitsUnwrapped,
                        experienceId: experienceID,
                        notes: ingestion.noteUnwrapped
                    )
                )
                currentIngestionID += 1
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
        }
        self.ingestions = ingestionsToStore
        self.experiences = experiencesToStore
        self.substanceCompanions = companionsToStore
        var customSubstancesToStore: [CustomSubstanceCodable] = []
        for customSubstanceIndex in 0..<customSubstances.count {
            let cust = customSubstances[customSubstanceIndex]
            customSubstancesToStore.append(
                CustomSubstanceCodable(
                    id: customSubstanceIndex + 1,
                    name: cust.nameUnwrapped,
                    units: cust.unitsUnwrapped,
                    description: cust.explanationUnwrapped
                )
            )
        }
        self.customSubstances = customSubstancesToStore
    }

    // Todo: check if this is necessary
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self = try JSONDecoder().decode(Self.self, from: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    // Todo: check if this is necessary
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}

struct ExperienceCodable: Codable {
    let id: Int
    let title: String
    let text: String
    let creationDate: Date
    let sortDate: Date?
}

struct IngestionCodable: Codable {
    let id: Int
    let substanceName: String
    let time: Date
    let creationDate: Date?
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let isDoseAnEstimate: Bool
    let units: String
    let experienceId: Int
    let notes: String
}

struct CompanionCodable: Codable {
    let substanceName: String
    let color: SubstanceColor

    enum CodingKeys: String, CodingKey {
        case substanceName
        case color
    }

    init(substanceName: String, color: SubstanceColor) {
        self.substanceName = substanceName
        self.color = color
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.substanceName = try values.decode(String.self, forKey: .substanceName)
        let colorCapitalized = try values.decode(String.self, forKey: .color)
        if let color = SubstanceColor(rawValue: colorCapitalized.lowercased()) {
            self.color = color
        } else {
            throw DecodingError.dataCorruptedError(in: try decoder.unkeyedContainer(), debugDescription: "\(colorCapitalized) is not a valid color")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(substanceName, forKey: .substanceName)
        try container.encode(color.rawValue.uppercased(), forKey: .color)
    }
}

struct CustomSubstanceCodable: Codable {
    let id: Int
    let name: String
    let units: String
    let description: String
}


