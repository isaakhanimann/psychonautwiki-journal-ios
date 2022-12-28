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

    init(
        id: Int,
        title: String,
        text: String,
        creationDate: Date,
        sortDate: Date?
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.creationDate = creationDate
        self.sortDate = sortDate
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case text
        case creationDate
        case sortDate
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.title = try values.decode(String.self, forKey: .title)
        self.text = try values.decode(String.self, forKey: .text)
        let creationDateMillis = try values.decode(UInt64.self, forKey: .creationDate)
        self.creationDate = getDateFromMillis(millis: creationDateMillis)
        if let sortDateMillis = try values.decodeIfPresent(UInt64.self, forKey: .sortDate) {
            self.sortDate = getDateFromMillis(millis: sortDateMillis)
        } else {
            self.sortDate = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(text, forKey: .text)
        try container.encode(UInt64(creationDate.timeIntervalSince1970) * 1000, forKey: .creationDate)
        if let sortDate {
            try container.encode(UInt64(sortDate.timeIntervalSince1970) * 1000, forKey: .sortDate)
        } else {
            let sortMillis: UInt64? = nil
            try container.encode(sortMillis, forKey: .sortDate)
        }
    }
}

struct IngestionCodable: Codable {
    let substanceName: String
    let time: Date
    let creationDate: Date?
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let isDoseAnEstimate: Bool
    let units: String
    let experienceId: Int
    let notes: String

    enum CodingKeys: String, CodingKey {
        case substanceName
        case time
        case creationDate
        case administrationRoute
        case dose
        case isDoseAnEstimate
        case units
        case experienceId
        case notes
    }

    init(
        substanceName: String,
        time: Date,
        creationDate: Date?,
        administrationRoute: AdministrationRoute,
        dose: Double?,
        isDoseAnEstimate: Bool,
        units: String,
        experienceId: Int,
        notes: String
    ) {
        self.substanceName = substanceName
        self.time = time
        self.creationDate = creationDate
        self.administrationRoute = administrationRoute
        self.dose = dose
        self.isDoseAnEstimate = isDoseAnEstimate
        self.units = units
        self.experienceId = experienceId
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.substanceName = try values.decode(String.self, forKey: .substanceName)
        let timeMillis = try values.decode(UInt64.self, forKey: .time)
        self.time = getDateFromMillis(millis: timeMillis)
        if let creationMillis = try values.decodeIfPresent(UInt64.self, forKey: .creationDate) {
            self.creationDate = getDateFromMillis(millis: creationMillis)
        } else {
            self.creationDate = nil
        }
        let routeString = try values.decode(String.self, forKey: .administrationRoute)
        if let route = AdministrationRoute(rawValue: routeString.lowercased()) {
            self.administrationRoute = route
        } else {
            throw DecodingError.dataCorruptedError(in: try decoder.unkeyedContainer(), debugDescription: "\(routeString) is not a valid route")
        }
        self.dose = try values.decode(Double.self, forKey: .dose)
        self.isDoseAnEstimate = try values.decode(Bool.self, forKey: .isDoseAnEstimate)
        self.units = try values.decode(String.self, forKey: .units)
        self.experienceId = try values.decode(Int.self, forKey: .experienceId)
        self.notes = try values.decode(String.self, forKey: .notes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(substanceName, forKey: .substanceName)
        try container.encode(UInt64(time.timeIntervalSince1970) * 1000, forKey: .time)
        if let creationDate {
            try container.encode(UInt64(creationDate.timeIntervalSince1970) * 1000, forKey: .creationDate)
        } else {
            let creationMillis: UInt64? = nil
            try container.encode(creationMillis, forKey: .creationDate)
        }
        try container.encode(administrationRoute.rawValue.uppercased(), forKey: .administrationRoute)
        try container.encode(dose, forKey: .dose)
        try container.encode(isDoseAnEstimate, forKey: .isDoseAnEstimate)
        try container.encode(units, forKey: .units)
        try container.encode(experienceId, forKey: .experienceId)
        try container.encode(notes, forKey: .notes)
    }
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

fileprivate func getDateFromMillis(millis: UInt64) -> Date {
    let secondsSince1970: TimeInterval = Double(millis)/1000
    return Date(timeIntervalSince1970: secondsSince1970)
}


