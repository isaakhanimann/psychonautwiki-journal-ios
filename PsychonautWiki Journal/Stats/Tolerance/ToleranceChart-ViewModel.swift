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

@available(iOS 16.0, *)
extension ToleranceChart {
    class ViewModel: ObservableObject {

        struct SubstanceAndDay {
            let substanceName: String
            let day: Date
        }

        func getToleranceWindows(from ingestions: [Ingestion], substanceCompanions: [SubstanceCompanion]) -> [ToleranceWindow] {
            let groupedIngestions = getIngestionsGroupedByDay(ingestions: ingestions)
            let substanceAndDays = getSubstanceAndDayPairs(groupedIngestions: groupedIngestions)
            return getToleranceWindows(from: substanceAndDays, substanceCompanions: substanceCompanions)
        }

        private func getToleranceWindows(from substanceAndDayPairs: [SubstanceAndDay], substanceCompanions: [SubstanceCompanion]) -> [ToleranceWindow] {
            return substanceAndDayPairs.flatMap { pair in
                let halfTolerance: TimeInterval = 5*24*60*60
                let zeroTolerance: TimeInterval = 10*24*60*60
                let alreadyUsedColors = substanceCompanions.map { $0.color }
                let substanceColor = substanceCompanions.first { com in
                    com.substanceNameUnwrapped == pair.substanceName
                }?.color ?? Set(SubstanceColor.allCases).subtracting(alreadyUsedColors).first ?? SubstanceColor.allCases.randomElement() ?? .blue
                let color = substanceColor.swiftUIColor
                return [
                    ToleranceWindow(
                        substanceName: pair.substanceName,
                        start: pair.day,
                        end: pair.day.addingTimeInterval(halfTolerance),
                        toleranceType: .full,
                        substanceColor: color),
                    ToleranceWindow(
                        substanceName: pair.substanceName,
                        start: pair.day,
                        end: pair.day.addingTimeInterval(zeroTolerance),
                        toleranceType: .half,
                        substanceColor: color)]
            }
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
