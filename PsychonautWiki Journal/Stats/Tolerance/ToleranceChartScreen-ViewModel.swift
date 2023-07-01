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

@available(iOS 16.0, *)
extension ToleranceChartScreen {
    class ViewModel: ObservableObject {

        @Published var toleranceWindows: [ToleranceWindow] = []

        struct SubstanceAndDay {
            let substanceName: String
            let day: Date
        }

        func setToleranceWindows(from ingestions: [Ingestion], substanceCompanions: [SubstanceCompanion]) {
            let groupedIngestions = getIngestionsGroupedByDay(ingestions: ingestions)
            let substanceAndDays = getSubstanceAndDayPairs(groupedIngestions: groupedIngestions)
            let substanceIntervals = getSubstanceIntervals(from: substanceAndDays)
            let substanceIntervalsGroupedBySubstance = getSubstanceIntervalsGroupedBySubstance(substanceIntervals: substanceIntervals)
            let mergedSubstanceIntervals = getMergedSubstanceIntervals(groupedSubstanceIntervals: substanceIntervalsGroupedBySubstance)
            let toleranceWindows = getToleranceWindows(from: mergedSubstanceIntervals, substanceCompanions: substanceCompanions)
            self.toleranceWindows = toleranceWindows
        }

        private func getToleranceWindows(from substanceIntervals: [SubstanceInterval], substanceCompanions: [SubstanceCompanion]) -> [ToleranceWindow] {
            substanceIntervals.map { substanceInterval in
                let color = getSubstanceColor(substanceName: substanceInterval.substanceName, substanceCompanions: substanceCompanions)
                return ToleranceWindow(
                    substanceName: substanceInterval.substanceName,
                    start: substanceInterval.dateInterval.start,
                    end: substanceInterval.dateInterval.end,
                    toleranceType: substanceInterval.toleranceType,
                    substanceColor: color)
            }
        }

        private func getSubstanceIntervalsGroupedBySubstance(substanceIntervals: [SubstanceInterval]) -> Dictionary<String, [SubstanceInterval]> {
            Dictionary(grouping: substanceIntervals) { interval in
                interval.substanceName
            }
        }

        private func getMergedSubstanceIntervals(groupedSubstanceIntervals: Dictionary<String, [SubstanceInterval]>) -> [SubstanceInterval] {
            groupedSubstanceIntervals.flatMap { substanceName, intervals in
                let fullToleranceIntervals = intervals.filter { $0.toleranceType == .full }.map { $0.dateInterval }
                let halfToleranceIntervals = intervals.filter { $0.toleranceType == .half }.map { $0.dateInterval }
                let mergedFullIntervals = mergeDateIntervals(fullToleranceIntervals)
                let halfWithoutFullIntervals = subtractIntervals(halfToleranceIntervals, subtracting: mergedFullIntervals)
                let mergedHalfIntervals = mergeDateIntervals(halfWithoutFullIntervals)
                let resultFull = mergedFullIntervals.map { dateInterval in
                    SubstanceInterval(
                        substanceName: substanceName,
                        dateInterval: dateInterval,
                        toleranceType: .full)
                }
                let resultHalf = mergedHalfIntervals.map { dateInterval in
                    SubstanceInterval(
                        substanceName: substanceName,
                        dateInterval: dateInterval,
                        toleranceType: .half)
                }
                return resultFull + resultHalf
            }
        }

        func subtractIntervals(_ intervals: [DateInterval], subtracting: [DateInterval]) -> [DateInterval] {
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

        private func getSubstanceIntervals(from substanceAndDayPairs: [SubstanceAndDay]) -> [SubstanceInterval] {
            substanceAndDayPairs.flatMap { pair in
                let halfTolerance: TimeInterval = 5*24*60*60
                let zeroTolerance: TimeInterval = 10*24*60*60
                let startOfHalfTolerance = pair.day.addingTimeInterval(halfTolerance)
                let startOfZeroTolerance = pair.day.addingTimeInterval(zeroTolerance)
                return [
                    SubstanceInterval(
                        substanceName: pair.substanceName,
                        dateInterval: DateInterval(start: pair.day, end: startOfHalfTolerance),
                        toleranceType: .full),
                    SubstanceInterval(
                        substanceName: pair.substanceName,
                        dateInterval: DateInterval(start: startOfHalfTolerance, end: startOfZeroTolerance),
                        toleranceType: .half)
                ]
            }
        }

        private func getSubstanceColor(substanceName: String , substanceCompanions: [SubstanceCompanion]) -> Color {
            let alreadyUsedColors = substanceCompanions.map { $0.color }
            let substanceColor = substanceCompanions.first { com in
                com.substanceNameUnwrapped == substanceName
            }?.color ?? Set(SubstanceColor.allCases).subtracting(alreadyUsedColors).first ?? SubstanceColor.allCases.randomElement() ?? .blue
            return substanceColor.swiftUIColor
        }

        private func mergeDateIntervals(_ intervals: [DateInterval]) -> [DateInterval] {
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

        private func getIngestionsGroupedByDay(ingestions: [Ingestion]) -> Dictionary<Date, [Ingestion]> {
            Dictionary(grouping: ingestions, by: { ing in
                dateWithoutTime(from: ing.timeUnwrapped)
            })
        }

        private func getSubstanceAndDayPairs(groupedIngestions: Dictionary<Date, [Ingestion]>) -> [SubstanceAndDay] {
            groupedIngestions.flatMap { day, ingestions in
                let substanceNames = Set(ingestions.map { ing in
                    ing.substanceNameUnwrapped
                })
                return substanceNames.map { name in
                    SubstanceAndDay(substanceName: name, day: day)
                }
            }
        }

        private func dateWithoutTime(from date: Date) -> Date {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(from: components) ?? date
        }
    }
}
