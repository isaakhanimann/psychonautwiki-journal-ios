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

struct TimedNoteCodable: Codable {
    let creationDate: Date
    let time: Date
    let note: String
    let color: SubstanceColor
    let isPartOfTimeline: Bool

    init(creationDate: Date, time: Date, note: String, color: SubstanceColor, isPartOfTimeline: Bool) {
        self.creationDate = creationDate
        self.time = time
        self.note = note
        self.color = color
        self.isPartOfTimeline = isPartOfTimeline
    }

    enum CodingKeys: String, CodingKey {
        case creationDate
        case time
        case note
        case color
        case isPartOfTimeline
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let creationDateMillis = try values.decode(UInt64.self, forKey: .creationDate)
        creationDate = getDateFromMillis(millis: creationDateMillis)
        let timeMillis = try values.decode(UInt64.self, forKey: .time)
        time = getDateFromMillis(millis: timeMillis)
        note = try values.decode(String.self, forKey: .note)
        color = try values.decode(SubstanceColor.self, forKey: .color)
        isPartOfTimeline = try values.decode(Bool.self, forKey: .isPartOfTimeline)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(UInt64(creationDate.timeIntervalSince1970) * 1000, forKey: .creationDate)
        try container.encode(UInt64(time.timeIntervalSince1970) * 1000, forKey: .time)
        try container.encode(note, forKey: .note)
        try container.encode(color.rawValue.uppercased(), forKey: .color)
        try container.encode(isPartOfTimeline, forKey: .isPartOfTimeline)
    }
}
