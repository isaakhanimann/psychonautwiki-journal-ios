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

import SwiftUI

enum ToleranceChartCalculator {
    static func getToleranceWindows(from substanceAndDays: [SubstanceAndDay], substanceCompanions: [SubstanceCompanion]) -> [ToleranceWindow] {
        let cleanedSubstanceAndDays = removeMultipleSubstancesInADay(substanceAndDays: substanceAndDays)
        let substanceIntervals = getSubstanceIntervals(from: cleanedSubstanceAndDays)
        let substanceIntervalsGroupedBySubstance = getSubstanceIntervalsGroupedBySubstance(substanceIntervals: substanceIntervals)
        let mergedSubstanceIntervals = getMergedSubstanceIntervals(intervalsGroupedBySubstance: substanceIntervalsGroupedBySubstance)
        let toleranceWindows = getToleranceWindows(from: mergedSubstanceIntervals, substanceCompanions: substanceCompanions)
        return toleranceWindows
    }

    private static func removeMultipleSubstancesInADay(substanceAndDays: [SubstanceAndDay]) -> [SubstanceAndDay] {
        Dictionary(grouping: substanceAndDays, by: { ing in
            ing.day.getDateWithoutTime()
        }).flatMap { day, substances in
            let substanceNames = Set(substances.map { $0.substanceName })
            return substanceNames.map { name in
                SubstanceAndDay(substanceName: name, day: day)
            }
        }
    }

    private static func getToleranceWindows(from substanceIntervals: [SubstanceInterval], substanceCompanions: [SubstanceCompanion]) -> [ToleranceWindow] {
        substanceIntervals.map { substanceInterval in
            let color = getSubstanceColor(substanceName: substanceInterval.substanceName, substanceCompanions: substanceCompanions)
            return ToleranceWindow(
                substanceName: substanceInterval.substanceName,
                start: substanceInterval.dateInterval.start,
                end: substanceInterval.dateInterval.end,
                toleranceType: substanceInterval.toleranceType,
                substanceColor: color
            )
        }
    }

    private static func getSubstanceIntervalsGroupedBySubstance(substanceIntervals: [SubstanceInterval]) -> [String: [SubstanceInterval]] {
        Dictionary(grouping: substanceIntervals) { interval in
            interval.substanceName
        }
    }

    private static func getMergedSubstanceIntervals(intervalsGroupedBySubstance: [String: [SubstanceInterval]]) -> [SubstanceInterval] {
        let groupedBySubstance = intervalsGroupedBySubstance.map { substanceName, intervals in
            let fullToleranceIntervals = intervals.filter { $0.toleranceType == .full }.map { $0.dateInterval }
            let halfToleranceIntervals = intervals.filter { $0.toleranceType == .half }.map { $0.dateInterval }
            let mergedFullIntervals = mergeDateIntervals(fullToleranceIntervals)
            let halfWithoutFullIntervals = subtractIntervals(halfToleranceIntervals, subtracting: mergedFullIntervals)
            let mergedHalfIntervals = mergeDateIntervals(halfWithoutFullIntervals)
            let resultFull = mergedFullIntervals.map { dateInterval in
                SubstanceInterval(
                    substanceName: substanceName,
                    dateInterval: dateInterval,
                    toleranceType: .full
                )
            }
            let resultHalf = mergedHalfIntervals.map { dateInterval in
                SubstanceInterval(
                    substanceName: substanceName,
                    dateInterval: dateInterval,
                    toleranceType: .half
                )
            }
            return resultFull + resultHalf
        }
        let sortedGroups = groupedBySubstance.sorted { (lhs: [SubstanceInterval], rhs: [SubstanceInterval]) in
            guard let maxLeft = lhs.filter({ $0.toleranceType == .full }).max(by: { leftInterval, rightInterval in
                leftInterval.dateInterval.end < rightInterval.dateInterval.end
            }) else { return true }
            guard let maxRight = rhs.filter({ $0.toleranceType == .full }).max(by: { leftInterval, rightInterval in
                leftInterval.dateInterval.end < rightInterval.dateInterval.end
            }) else { return true }
            return maxLeft.dateInterval.end < maxRight.dateInterval.end
        }
        return sortedGroups.flatMap { $0 }
    }

    private static func subtractIntervals(_ intervals: [DateInterval], subtracting: [DateInterval]) -> [DateInterval] {
        var result: [DateInterval] = []
        for interval in intervals {
            var remaining: [DateInterval] = [interval]
            for sub in subtracting {
                remaining = remaining.flatMap { res -> [DateInterval] in
                    // If the interval doesn't intersect with the subtracting interval, return it as is
                    guard res.intersects(sub) else { return [res] }
                    var newIntervals: [DateInterval] = []
                    // If there's a part of the interval before the subtracting interval, add it to the new intervals
                    if res.start < sub.start {
                        newIntervals.append(DateInterval(start: res.start, end: sub.start))
                    }
                    // If there's a part of the interval after the subtracting interval, add it to the new intervals
                    if res.end > sub.end {
                        newIntervals.append(DateInterval(start: sub.end, end: res.end))
                    }
                    return newIntervals
                }
            }
            result.append(contentsOf: remaining)
        }
        return result
    }

    struct SubstanceInterval {
        let substanceName: String
        let dateInterval: DateInterval
        let toleranceType: ToleranceType
    }

    private static func getSubstanceIntervals(from substanceAndDayPairs: [SubstanceAndDay]) -> [SubstanceInterval] {
        substanceAndDayPairs.flatMap { pair in
            let tolerance = SubstanceRepo.shared.getSubstance(name: pair.substanceName)?.tolerance
            var result = [SubstanceInterval]()
            var startOfHalfTolerance = pair.day
            let hoursToSeconds: Double = 60 * 60
            if let halfToleranceInHours = tolerance?.halfToleranceInHours, halfToleranceInHours > 24 {
                let halfTolerance: TimeInterval = halfToleranceInHours * hoursToSeconds
                startOfHalfTolerance = pair.day.addingTimeInterval(halfTolerance)
                result.append(SubstanceInterval(
                    substanceName: pair.substanceName,
                    dateInterval: DateInterval(start: pair.day, end: startOfHalfTolerance),
                    toleranceType: .full
                ))
            }
            if let zeroToleranceInHours = tolerance?.zeroToleranceInHours, zeroToleranceInHours > 24 {
                let zeroTolerance: TimeInterval = zeroToleranceInHours * hoursToSeconds
                let startOfZeroTolerance = pair.day.addingTimeInterval(zeroTolerance)
                result.append(SubstanceInterval(
                    substanceName: pair.substanceName,
                    dateInterval: DateInterval(start: startOfHalfTolerance, end: startOfZeroTolerance),
                    toleranceType: .half
                ))
            }
            return result
        }
    }

    private static func getSubstanceColor(substanceName: String, substanceCompanions: [SubstanceCompanion]) -> Color {
        let alreadyUsedColors = substanceCompanions.map { $0.color }
        let substanceColor = substanceCompanions.first { com in
            com.substanceNameUnwrapped == substanceName
        }?.color ?? Set(SubstanceColor.allCases).subtracting(alreadyUsedColors).first ?? SubstanceColor.allCases.randomElement() ?? .blue
        return substanceColor.swiftUIColor
    }

    private static func mergeDateIntervals(_ intervals: [DateInterval]) -> [DateInterval] {
        guard !intervals.isEmpty else { return [] }
        var sortedIntervals = intervals.sorted(by: { $0.start < $1.start })
        var mergedIntervals: [DateInterval] = [sortedIntervals.removeFirst()]
        for interval in sortedIntervals {
            guard let last = mergedIntervals.last else { continue }
            if interval.start <= last.end {
                // The intervals overlap, extend the last interval if necessary
                let extendedEnd = max(last.end, interval.end)
                // Remove the last interval and append the extended one
                mergedIntervals.removeLast()
                mergedIntervals.append(DateInterval(start: last.start, end: extendedEnd))
            } else {
                // The intervals don't overlap, add the current interval to the merged list
                mergedIntervals.append(interval)
            }
        }
        return mergedIntervals
    }
}
