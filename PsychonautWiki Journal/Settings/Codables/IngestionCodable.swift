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
    let endTime: Date?
    let creationDate: Date?
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let estimatedDoseStandardDeviation: Double?
    let isDoseAnEstimate: Bool
    let units: String
    let notes: String
    let stomachFullness: StomachFullness?
    let consumerName: String?
    let customUnitId: Int32?

    enum CodingKeys: String, CodingKey {
        case substanceName
        case time
        case endTime
        case creationDate
        case administrationRoute
        case dose
        case estimatedDoseStandardDeviation
        case isDoseAnEstimate
        case units
        case notes
        case stomachFullness
        case consumerName
        case customUnitId
    }

    init(
        substanceName: String,
        time: Date,
        endTime: Date?,
        creationDate: Date?,
        administrationRoute: AdministrationRoute,
        dose: Double?,
        estimatedDoseStandardDeviation: Double?,
        isDoseAnEstimate: Bool,
        units: String,
        notes: String,
        stomachFullness: StomachFullness?,
        consumerName: String?,
        customUnitId: Int32?
    ) {
        self.substanceName = substanceName
        self.time = time
        self.endTime = endTime
        self.creationDate = creationDate
        self.administrationRoute = administrationRoute
        self.dose = dose
        self.estimatedDoseStandardDeviation =                         estimatedDoseStandardDeviation
        self.isDoseAnEstimate = isDoseAnEstimate
        self.units = units
        self.notes = notes
        self.stomachFullness = stomachFullness
        self.consumerName = consumerName
        self.customUnitId = customUnitId
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        substanceName = try values.decode(String.self, forKey: .substanceName)
        let timeMillis = try values.decode(UInt64.self, forKey: .time)
        time = getDateFromMillis(millis: timeMillis)
        if let endTimeMillis = try values.decodeIfPresent(UInt64.self, forKey: .endTime) {
            endTime = getDateFromMillis(millis: endTimeMillis)
        } else {
            endTime = nil
        }
        if let creationMillis = try values.decodeIfPresent(UInt64.self, forKey: .creationDate) {
            creationDate = getDateFromMillis(millis: creationMillis)
        } else {
            creationDate = nil
        }
        let routeString = try values.decode(String.self, forKey: .administrationRoute)
        if let route = AdministrationRoute(rawValue: routeString.lowercased()) {
            administrationRoute = route
        } else {
            throw try DecodingError.dataCorruptedError(in: decoder.unkeyedContainer(), debugDescription: "\(routeString) is not a valid route")
        }
        dose = try values.decodeIfPresent(Double.self, forKey: .dose)
        estimatedDoseStandardDeviation = try values.decodeIfPresent(Double.self, forKey: .estimatedDoseStandardDeviation)
        isDoseAnEstimate = try values.decode(Bool.self, forKey: .isDoseAnEstimate)
        units = try values.decode(String.self, forKey: .units)
        notes = try values.decode(String.self, forKey: .notes)
        if let fullnessString = try values.decodeIfPresent(String.self, forKey: .stomachFullness) {
            if let fullness = StomachFullness(rawValue: fullnessString.lowercased()) {
                stomachFullness = fullness
            } else {
                stomachFullness = nil
            }
        } else {
            stomachFullness = nil
        }
        consumerName = try values.decodeIfPresent(String.self, forKey: .consumerName)
        customUnitId = try values.decodeIfPresent(Int32.self, forKey: .customUnitId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(substanceName, forKey: .substanceName)
        try container.encode(UInt64(time.timeIntervalSince1970) * 1000, forKey: .time)
        if let endTime {
            try container.encode(UInt64(endTime.timeIntervalSince1970) * 1000, forKey: .endTime)
        } else {
            let endTimeMillis: UInt64? = nil
            try container.encode(endTimeMillis, forKey: .endTime)
        }
        if let creationDate {
            try container.encode(UInt64(creationDate.timeIntervalSince1970) * 1000, forKey: .creationDate)
        } else {
            let creationMillis: UInt64? = nil
            try container.encode(creationMillis, forKey: .creationDate)
        }
        try container.encode(administrationRoute.rawValue.uppercased(), forKey: .administrationRoute)
        try container.encode(dose, forKey: .dose)
        try container.encode(estimatedDoseStandardDeviation, forKey: .estimatedDoseStandardDeviation)
        try container.encode(isDoseAnEstimate, forKey: .isDoseAnEstimate)
        try container.encode(units, forKey: .units)
        try container.encode(notes, forKey: .notes)
        try container.encode(stomachFullness?.rawValue.uppercased(), forKey: .stomachFullness)
        try container.encode(consumerName, forKey: .consumerName)
        try container.encode(customUnitId, forKey: .customUnitId)
    }
}
