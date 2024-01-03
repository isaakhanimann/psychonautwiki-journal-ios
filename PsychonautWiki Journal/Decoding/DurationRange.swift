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

struct DurationRange: Codable {
    let min: Double?
    let max: Double?
    let units: Units

    enum Units: String, CaseIterable, Codable {
        case seconds, minutes, hours, days
    }

    var isFullyDefined: Bool {
        guard let minUnwrap = min else { return false }
        guard let maxUnwrap = max else { return false }
        return minUnwrap <= maxUnwrap
    }

    var minSec: Double? {
        convertToSec(value: min)
    }

    var maxSec: Double? {
        convertToSec(value: max)
    }

    var displayString: String? {
        guard min != nil || max != nil else { return nil }
        let min = min?.formatted() ?? ".."
        let max = max?.formatted() ?? ".."
        var result = "\(min)-\(max)"
        switch units {
        case .seconds:
            result += "s"
        case .minutes:
            result += "m"
        case .hours:
            result += "h"
        case .days:
            result += "d"
        }
        return result
    }

    private func convertToSec(value: Double?) -> Double? {
        guard var convert = value else { return nil }
        var unit: UnitDuration
        switch units {
        case .seconds:
            unit = UnitDuration.seconds
        case .minutes:
            unit = UnitDuration.minutes
        case .hours:
            unit = UnitDuration.hours
        case .days:
            convert *= 24
            unit = UnitDuration.hours
        }
        return Measurement(value: convert, unit: unit).converted(to: .seconds).value
    }

    var maybeFullDurationRange: FullDurationRange? {
        if let min = minSec, let max = maxSec {
            return FullDurationRange(min: min, max: max)
        } else {
            return nil
        }
    }
}

struct FullDurationRange {
    let min: TimeInterval
    let max: TimeInterval

    func interpolateLinearly(at weightBetween0And1: Double) -> TimeInterval {
        let diff = max - min
        return min + (diff * weightBetween0And1)
    }
}
