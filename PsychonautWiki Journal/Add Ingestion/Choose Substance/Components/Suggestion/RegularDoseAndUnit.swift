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

struct RegularDoseAndUnit: Equatable, Identifiable {
    var id: String {
        (dose?.description ?? "") + units + isEstimate.description + (estimatedDoseStandardDeviation?.description ?? "")
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.doseDescription == rhs.doseDescription
    }

    let dose: Double?
    let units: String
    let isEstimate: Bool
    let estimatedDoseStandardDeviation: Double?

    var doseDescription: String? {
        if let dose {
            if isEstimate {
                if let estimatedDoseStandardDeviation {
                    return "\(dose.formatted())±\(estimatedDoseStandardDeviation.formatted()) \(units)"
                } else {
                    return "~\(dose.formatted()) \(units)"
                }
            } else {
                return "\(dose.formatted()) \(units)"
            }
        } else {
            return nil
        }
    }
}
