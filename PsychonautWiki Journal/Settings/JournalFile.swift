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
            experiencesToStore.append(
                ExperienceCodable(
                    title: experience.titleUnwrapped,
                    text: experience.textUnwrapped,
                    creationDate: experience.creationDateUnwrapped,
                    sortDate: experience.sortDate,
                    isFavorite: experience.isFavorite,
                    ingestions: ingestionsInExperience,
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
    let title: String
    let text: String
    let creationDate: Date
    let sortDate: Date?
    let isFavorite: Bool
    let ingestions: [IngestionCodable]
    let location: LocationCodable?

    init(
        title: String,
        text: String,
        creationDate: Date,
        sortDate: Date?,
        isFavorite: Bool,
        ingestions: [IngestionCodable],
        experienceLocation: ExperienceLocation?
    ) {
        self.title = title
        self.text = text
        self.creationDate = creationDate
        self.sortDate = sortDate
        self.isFavorite = isFavorite
        self.ingestions = ingestions
        if let experienceLocation {
            self.location = LocationCodable(
                name: experienceLocation.nameUnwrapped,
                latitude: experienceLocation.latitudeUnwrapped,
                longitude: experienceLocation.longitudeUnwrapped
            )
        } else {
            self.location = nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case title
        case text
        case creationDate
        case sortDate
        case isFavorite
        case ingestions
        case location
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try values.decode(String.self, forKey: .title)
        self.text = try values.decode(String.self, forKey: .text)
        let creationDateMillis = try values.decode(UInt64.self, forKey: .creationDate)
        self.creationDate = getDateFromMillis(millis: creationDateMillis)
        if let sortDateMillis = try values.decodeIfPresent(UInt64.self, forKey: .sortDate) {
            self.sortDate = getDateFromMillis(millis: sortDateMillis)
        } else {
            self.sortDate = nil
        }
        self.isFavorite = (try values.decodeIfPresent(Bool.self, forKey: .isFavorite)) ?? false
        self.ingestions = try values.decode([IngestionCodable].self, forKey: .ingestions)
        self.location = try values.decodeIfPresent(LocationCodable.self, forKey: .location)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(text, forKey: .text)
        try container.encode(UInt64(creationDate.timeIntervalSince1970) * 1000, forKey: .creationDate)
        if let sortDate {
            try container.encode(UInt64(sortDate.timeIntervalSince1970) * 1000, forKey: .sortDate)
        } else {
            let sortMillis: UInt64? = nil
            try container.encode(sortMillis, forKey: .sortDate)
        }
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(ingestions, forKey: .ingestions)
        try container.encode(location, forKey: .location)
    }
}

struct LocationCodable: Codable {
    let name: String
    let latitude: Double?
    let longitude: Double?
}

struct IngestionCodable: Codable {
    let substanceName: String
    let time: Date
    let creationDate: Date?
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let isDoseAnEstimate: Bool
    let units: String
    let notes: String

    enum CodingKeys: String, CodingKey {
        case substanceName
        case time
        case creationDate
        case administrationRoute
        case dose
        case isDoseAnEstimate
        case units
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
        notes: String
    ) {
        self.substanceName = substanceName
        self.time = time
        self.creationDate = creationDate
        self.administrationRoute = administrationRoute
        self.dose = dose
        self.isDoseAnEstimate = isDoseAnEstimate
        self.units = units
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
    let name: String
    let units: String
    let description: String
}

fileprivate func getDateFromMillis(millis: UInt64) -> Date {
    let secondsSince1970: TimeInterval = Double(millis)/1000
    return Date(timeIntervalSince1970: secondsSince1970)
}


