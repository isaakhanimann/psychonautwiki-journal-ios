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

import Foundation

struct AxisDrawable {
    let startTime: Date
    let widthInSeconds: TimeInterval

    func getFullHours(pixelsPerSec: Double, widthInPixels: Double) -> [FullHour] {
        let widthInWholeHours = (widthInSeconds / 60 / 60).rounded(.up)
        let widthPerHour = widthInPixels / widthInWholeHours
        let minWidthPerHour: Double = 30
        var stepSize = Int(minWidthPerHour / widthPerHour)
        if stepSize == 0 {
            stepSize = 1
        }
        let dates = AxisDrawable.getInstantsBetween(
            startTime: startTime,
            endTime: startTime + widthInSeconds,
            stepSizeInHours: stepSize
        )
        var fullHours = dates.map { date in
            let diff = date.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
            return FullHour(
                distanceFromStart: diff * pixelsPerSec,
                label: String(Calendar.current.component(.hour, from: date))
            )
        }
        let widthOfOneLetter: Double = 7
        if let firstHour = fullHours.first, firstHour.distanceFromStart < widthOfOneLetter {
            fullHours = Array(fullHours.dropFirst())
        }
        if let lastHour = fullHours.last, widthInPixels - lastHour.distanceFromStart < widthOfOneLetter {
            fullHours = Array(fullHours.dropLast())
        }
        return fullHours
    }

    static func getInstantsBetween(startTime: Date, endTime: Date, stepSizeInHours: Int) -> [Date] {
        let firstDate = startTime.nearestFullHourInTheFuture
        var checkTime = firstDate
        var fullHours: [Date] = []
        while checkTime < endTime {
            fullHours.append(checkTime)
            guard let nextCheckTime = Calendar.current.date(byAdding: .hour, value: stepSizeInHours, to: checkTime) else { break }
            checkTime = nextCheckTime
        }
        return fullHours
    }
}

extension Date {
    var nearestFullHourInTheFuture: Date {
        let oneHour: TimeInterval = 60 * 60
        let oneHourInFuture = addingTimeInterval(oneHour)
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: oneHourInFuture)
        components.minute = 0
        components.second = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
}

struct FullHour {
    let distanceFromStart: Double
    let label: String
}
