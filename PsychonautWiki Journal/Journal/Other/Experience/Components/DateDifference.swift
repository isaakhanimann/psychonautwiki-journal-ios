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

enum DateDifference {

    static func maxTwoUnitsBetween(_ startDate: Date, and endDate: Date) -> String {
        let components = between(startDate, and: endDate)
        return formattedWithMax2Units(components)
    }

    static func formattedWithAtLeastDaysBetween(_ startDate: Date, and endDate: Date) -> String {
        let components = between(startDate, and: endDate)
        return formattedWithAtLeastDays(components)
    }

    static func between(_ startDate: Date, and endDate: Date) -> DateComponents {
        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let dateDifference = calendar.dateComponents(components, from: startDate, to: endDate)
        return dateDifference
    }

    static func formattedWithMax2Units(_ dateComponents: DateComponents) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .brief
        return formatter.string(from: dateComponents) ?? ""
    }

    private static func formattedWithAtLeastDays(_ dateComponents: DateComponents) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .brief
        return formatter.string(from: dateComponents) ?? ""
    }
}
