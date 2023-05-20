// Copyright (c) 2023. Isaak Hanimann.
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

struct IngestionCodable: Codable {
    let substanceName: String
    let time: Date
    let creationDate: Date?
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let isDoseAnEstimate: Bool
    let units: String
    let notes: String
    let stomachFullness: StomachFullness?

    enum CodingKeys: String, CodingKey {
        case substanceName
        case time
        case creationDate
        case administrationRoute
        case dose
        case isDoseAnEstimate
        case units
        case notes
        case stomachFullness
    }

    init(
        substanceName: String,
        time: Date,
        creationDate: Date?,
        administrationRoute: AdministrationRoute,
        dose: Double?,
        isDoseAnEstimate: Bool,
        units: String,
        notes: String,
        stomachFullness: StomachFullness?
    ) {
        self.substanceName = substanceName
        self.time = time
        self.creationDate = creationDate
        self.administrationRoute = administrationRoute
        self.dose = dose
        self.isDoseAnEstimate = isDoseAnEstimate
        self.units = units
        self.notes = notes
        self.stomachFullness = stomachFullness
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
        self.dose = try values.decodeIfPresent(Double.self, forKey: .dose)
        self.isDoseAnEstimate = try values.decode(Bool.self, forKey: .isDoseAnEstimate)
        self.units = try values.decode(String.self, forKey: .units)
        self.notes = try values.decode(String.self, forKey: .notes)
        if let fullnessString = try values.decodeIfPresent(String.self, forKey: .stomachFullness) {
            if let fullness = StomachFullness(rawValue: fullnessString.lowercased()) {
                self.stomachFullness = fullness
            } else {
                self.stomachFullness = nil
            }
        } else {
            self.stomachFullness = nil
        }

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
        try container.encode(stomachFullness?.rawValue.uppercased(), forKey: .stomachFullness)
    }
}
