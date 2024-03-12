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

import SwiftUI

func date(year: Int, month: Int = 1, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

struct SubstanceCount: Identifiable, Hashable {
    var id: String {
        substanceName
    }

    let substanceName: String
    let experienceCount: Int
}

struct SubstanceData: Hashable, Equatable {
    static func == (lhs: SubstanceData, rhs: SubstanceData) -> Bool {
        lhs.years == rhs.years
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(last30Days)
        hasher.combine(last12Months)
        hasher.combine(years)
    }

    let last30Days: [SubstanceCount]
    let last12Months: [SubstanceCount]
    let years: [SubstanceCount]
    let colorMapping: (String) -> Color
}

extension SubstanceData {
    static let mock1 = SubstanceData(
        last30Days: [
            .init(substanceName: "Cannabis", experienceCount: 15),
            .init(substanceName: "Cocaine", experienceCount: 8),
            .init(substanceName: "Amphetamine", experienceCount: 3),
            .init(substanceName: "MDMA", experienceCount: 1),
        ],
        last12Months: [
            .init(substanceName: "Cannabis", experienceCount: 55),
            .init(substanceName: "Cocaine", experienceCount: 10),
            .init(substanceName: "MDMA", experienceCount: 4),
            .init(substanceName: "Amphetamine", experienceCount: 3),
        ],
        years: [
            .init(substanceName: "Cannabis", experienceCount: 60),
            .init(substanceName: "Cocaine", experienceCount: 15),
            .init(substanceName: "MDMA", experienceCount: 8),
            .init(substanceName: "Amphetamine", experienceCount: 8),
        ],
        colorMapping: { substanceName in
            switch substanceName {
            case "MDMA": return Color.pink
            case "Cannabis": return .green
            case "Cocaine": return .blue
            case "Amphetamine": return .cyan
            case "LSD": return .purple
            default: return .red
            }
        }
    )
    static let mock2 = SubstanceData(
        last30Days: [
            .init(substanceName: "Cannabis", experienceCount: 15),
            .init(substanceName: "Cocaine", experienceCount: 8),
            .init(substanceName: "Amphetamine", experienceCount: 3),
            .init(substanceName: "MDMA", experienceCount: 1),
        ],
        last12Months: [
            .init(substanceName: "Cannabis", experienceCount: 55),
            .init(substanceName: "Cocaine", experienceCount: 10),
            .init(substanceName: "MDMA", experienceCount: 4),
            .init(substanceName: "Substance 1", experienceCount: 4),
            .init(substanceName: "Substance 2", experienceCount: 4),
            .init(substanceName: "Substance 3", experienceCount: 4),
            .init(substanceName: "Substance 4", experienceCount: 4),
            .init(substanceName: "Substance 5", experienceCount: 4),
            .init(substanceName: "Substance 6", experienceCount: 4),
            .init(substanceName: "Substance 7", experienceCount: 4),
            .init(substanceName: "Substance 8", experienceCount: 4),
            .init(substanceName: "Substance 9", experienceCount: 4),
            .init(substanceName: "Substance 10", experienceCount: 4),
            .init(substanceName: "Substance 11", experienceCount: 4),
            .init(substanceName: "Substance 12", experienceCount: 4),
            .init(substanceName: "Substance 13", experienceCount: 4),
            .init(substanceName: "Substance 14", experienceCount: 4),
            .init(substanceName: "Substance 15", experienceCount: 4),
            .init(substanceName: "Substance 16", experienceCount: 4),
            .init(substanceName: "Substance 17", experienceCount: 4),
            .init(substanceName: "Substance 18", experienceCount: 4),
            .init(substanceName: "Substance 19", experienceCount: 4),
            .init(substanceName: "Substance 20", experienceCount: 4),
            .init(substanceName: "Substance 21", experienceCount: 4),
            .init(substanceName: "Substance 22", experienceCount: 4),
            .init(substanceName: "Substance 23", experienceCount: 4),
            .init(substanceName: "Substance 24", experienceCount: 4),
            .init(substanceName: "Substance 25", experienceCount: 4),
            .init(substanceName: "Substance 26", experienceCount: 4),
            .init(substanceName: "Substance 27", experienceCount: 4),
            .init(substanceName: "Substance 28", experienceCount: 4),
            .init(substanceName: "Substance 29", experienceCount: 4),
            .init(substanceName: "Substance 30", experienceCount: 4),
            .init(substanceName: "Substance 31", experienceCount: 4),
            .init(substanceName: "Amphetamine", experienceCount: 3),
        ],
        years: [
            .init(substanceName: "Cannabis", experienceCount: 60),
            .init(substanceName: "Cocaine", experienceCount: 15),
            .init(substanceName: "MDMA", experienceCount: 8),
            .init(substanceName: "Amphetamine", experienceCount: 8),
        ],
        colorMapping: { substanceName in
            switch substanceName {
            case "MDMA": return Color.pink
            case "Cannabis": return .green
            case "Cocaine": return .blue
            case "Amphetamine": return .cyan
            case "LSD": return .purple
            default: return SubstanceColor.allCases.randomElement()!.swiftUIColor
            }
        }
    )
}

struct SubstanceExperienceCountForDay: Identifiable, Hashable {
    var id: String {
        day.asDateAndTime + substanceName
    }

    let day: Date
    let substanceName: String
    let experienceCount: Double
}

struct SubstanceExperienceCountForMonth: Hashable {
    let month: Date
    let substanceName: String
    let experienceCount: Double
}

struct SubstanceExperienceCountForYear: Hashable {
    let year: Date
    let substanceName: String
    let experienceCount: Double
}

struct ExperienceData: Hashable, Equatable {
    static func == (lhs: ExperienceData, rhs: ExperienceData) -> Bool {
        lhs.years == rhs.years
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(last30Days)
        hasher.combine(last12Months)
        hasher.combine(years)
    }

    let last30Days: [SubstanceExperienceCountForDay]
    let last12Months: [SubstanceExperienceCountForMonth]
    let years: [SubstanceExperienceCountForYear]
    let colorMapping: (String) -> Color

    var last30DaysTotal: Double {
        last30Days.map { $0.experienceCount }.reduce(0, +)
    }

    var last12MonthsTotal: Double {
        last12Months.map { $0.experienceCount }.reduce(0, +)
    }

    var yearsTotal: Double {
        years.map { $0.experienceCount }.reduce(0, +)
    }

    var monthlyAverage: Double {
        var dates = last12Months.map { $0.month }
        guard let minDate = dates.min() else { return 0 }
        guard let maxDate = dates.max() else { return 0 }
        guard var fillDate = Calendar.current.date(byAdding: .month, value: 1, to: minDate) else { return 0 }
        while fillDate < maxDate {
            dates.append(fillDate)
            guard let newFill = Calendar.current.date(byAdding: .month, value: 1, to: fillDate) else { return 0 }
            fillDate = newFill
        }
        let numberOfMonthsShown = dates.map { $0.asYearAndMonth }.uniqued().count
        guard numberOfMonthsShown > 0 else { return 0 }
        return last12MonthsTotal / Double(numberOfMonthsShown)
    }

    var yearlyAverage: Double {
        var dates = years.map { $0.year }
        guard let minDate = dates.min() else { return 0 }
        guard let maxDate = dates.max() else { return 0 }
        guard var fillDate = Calendar.current.date(byAdding: .year, value: 1, to: minDate) else { return 0 }
        while fillDate < maxDate {
            dates.append(fillDate)
            guard let newFill = Calendar.current.date(byAdding: .year, value: 1, to: fillDate) else { return 0 }
            fillDate = newFill
        }
        let numberOfYearsShown = dates.map { $0.asYear }.uniqued().count
        guard numberOfYearsShown > 0 else { return 0 }
        return yearsTotal / Double(numberOfYearsShown)
    }

    func getSubstanceExperienceCounts(in timeRange: TimeRange) -> [SubstanceExperienceCount] {
        switch timeRange {
        case .last30Days:
            let dict = Dictionary(grouping: last30Days) { elem in
                elem.substanceName
            }
            return dict.map { (name: String, counts: [SubstanceExperienceCountForDay]) in
                SubstanceExperienceCount(
                    substanceName: name,
                    experienceCount: counts.map { $0.experienceCount }.reduce(0, +),
                    color: colorMapping(name)
                )
            }
            .filter { elem in
                elem.experienceCount > 0
            }
            .sorted()
        case .last12Months:
            let dict = Dictionary(grouping: last12Months) { elem in
                elem.substanceName
            }
            return dict.map { (name: String, counts: [SubstanceExperienceCountForMonth]) in
                SubstanceExperienceCount(
                    substanceName: name,
                    experienceCount: counts.map { $0.experienceCount }.reduce(0, +),
                    color: colorMapping(name)
                )
            }
            .filter { elem in
                elem.experienceCount > 0
            }
            .sorted()
        case .years:
            let dict = Dictionary(grouping: years) { elem in
                elem.substanceName
            }
            return dict.map { (name: String, counts: [SubstanceExperienceCountForYear]) in
                SubstanceExperienceCount(
                    substanceName: name,
                    experienceCount: counts.map { $0.experienceCount }.reduce(0, +),
                    color: colorMapping(name)
                )
            }
            .filter { elem in
                elem.experienceCount > 0
            }
            .sorted()
        }
    }
}

struct SubstanceExperienceCount: Identifiable, Comparable {
    static func < (lhs: SubstanceExperienceCount, rhs: SubstanceExperienceCount) -> Bool {
        lhs.experienceCount > rhs.experienceCount
    }

    var id: String {
        substanceName
    }

    let substanceName: String
    let experienceCount: Double
    let color: Color
}

extension ExperienceData {
    static let mock1 = ExperienceData(
        last30Days: [
            .init(day: date(year: 2022, month: 5, day: 8), substanceName: "MDMA", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 8), substanceName: "Cannabis", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 9), substanceName: "Cannabis", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 10), substanceName: "Cannabis", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 13), substanceName: "Cocaine", experienceCount: 1.0 / 3),
            .init(day: date(year: 2022, month: 5, day: 13), substanceName: "Amphetamine", experienceCount: 1.0 / 3),
            .init(day: date(year: 2022, month: 5, day: 13), substanceName: "LSD", experienceCount: 1.0 / 3),
            .init(day: date(year: 2022, month: 5, day: 14), substanceName: "Cannabis", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 15), substanceName: "MDMA", experienceCount: 1),
            .init(day: date(year: 2022, month: 5, day: 25), substanceName: "Cocaine", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 25), substanceName: "MDMA", experienceCount: 0.5),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Cannabis", experienceCount: 0.25),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Amphetamine", experienceCount: 0.25),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "MDMA", experienceCount: 0.25),
            .init(day: date(year: 2022, month: 5, day: 27), substanceName: "Cocaine", experienceCount: 0.25),
        ],
        last12Months: [
            .init(month: date(year: 2021, month: 7), substanceName: "MDMA", experienceCount: 1),
            .init(month: date(year: 2021, month: 7), substanceName: "Cocaine", experienceCount: 2),
            .init(month: date(year: 2021, month: 7), substanceName: "Cannabis", experienceCount: 10),
            .init(month: date(year: 2021, month: 8), substanceName: "Cocaine", experienceCount: 1),
            .init(month: date(year: 2021, month: 8), substanceName: "Cannabis", experienceCount: 5),
            .init(month: date(year: 2021, month: 9), substanceName: "Amphetamine", experienceCount: 2),
            .init(month: date(year: 2021, month: 9), substanceName: "Cannabis", experienceCount: 3),
            .init(month: date(year: 2022, month: 1), substanceName: "MDMA", experienceCount: 1),
            .init(month: date(year: 2022, month: 1), substanceName: "Cannabis", experienceCount: 5),
            .init(month: date(year: 2022, month: 3), substanceName: "Amphetamine", experienceCount: 3),
        ],
        years: [
            .init(year: date(year: 2021), substanceName: "MDMA", experienceCount: 3),
            .init(year: date(year: 2021), substanceName: "Cocaine", experienceCount: 4),
            .init(year: date(year: 2021), substanceName: "Cannabis", experienceCount: 20),
            .init(year: date(year: 2021), substanceName: "Amphetamine", experienceCount: 5),
            .init(year: date(year: 2022), substanceName: "MDMA", experienceCount: 5),
            .init(year: date(year: 2022), substanceName: "Cannabis", experienceCount: 15),
            .init(year: date(year: 2022), substanceName: "Amphetamine", experienceCount: 6),
            .init(year: date(year: 2022), substanceName: "Cocaine", experienceCount: 2),
        ],
        colorMapping: { substanceName in
            switch substanceName {
            case "MDMA": return Color.pink
            case "Cannabis": return .green
            case "Cocaine": return .blue
            case "Amphetamine": return .cyan
            case "LSD": return .purple
            default: return .red
            }
        }
    )
}
