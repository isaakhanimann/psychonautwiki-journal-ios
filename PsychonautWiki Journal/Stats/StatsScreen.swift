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
import Charts

@available(iOS 16, *)
struct StatsScreen: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)],
        predicate: NSPredicate(format: "consumerName=nil OR consumerName=''")
    ) var ingestions: FetchedResults<Ingestion>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false)]
    ) var experiences: FetchedResults<Experience>

    @FetchRequest(
        sortDescriptors: []
    ) var substanceCompanions: FetchedResults<SubstanceCompanion>

    @State private var experienceData: ExperienceData? = nil
    @State private var substanceData: SubstanceData? = nil
    @State private var toleranceWindows: [ToleranceWindow] = []
    @State private var substancesInIngestionsButNotChart: [String] = []
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            Group {
                if let experienceData, let substanceData {
                    StatsScreenContent(
                        experienceData: experienceData,
                        substanceData: substanceData,
                        toleranceWindows: toleranceWindows,
                        substancesInIngestionsButNotChart: substancesInIngestionsButNotChart,
                        isEyeOpen: isEyeOpen
                    )
                } else {
                    ProgressView().task {
                        calculateStats()
                    }
                }
            }.onChange(of: ingestions.count) { newValue in
                calculateStats()
            }
        }
        .navigationViewStyle(.stack)
    }

    private func calculateStats() {
        experienceData = ExperienceData(
            last30Days: getExperienceCountsLast30Days(),
            last12Months: getExperienceCountsLast12Months(),
            years: getExperienceCountsYears(),
            colorMapping: { substanceName in
                getColor(for: substanceName).swiftUIColor
            }
        )
        substanceData = SubstanceData(
            last30Days: getSortedSubstanceCountsLast30Days(),
            last12Months: getSortedSubstanceCountsLast12Months(),
            years: getSortedSubstanceCountsYears(),
            colorMapping: { substanceName in
                getColor(for: substanceName).swiftUIColor
            }
        )
        let ingestionsLast90Days = ingestions.prefix { ing in
            Calendar.current.numberOfDaysBetween(ing.timeUnwrapped, and: Date()) <= 90
        }
        let substanceDays = ingestionsLast90Days.map { ing in
            SubstanceAndDay(substanceName: ing.substanceNameUnwrapped, day: ing.timeUnwrapped)
        }
        toleranceWindows = ToleranceChartCalculator.getToleranceWindows(
            from: substanceDays,
            substanceCompanions: Array(substanceCompanions)
        )
        let substancesInIngestions = Set(ingestionsLast90Days.map({$0.substanceNameUnwrapped}))
        let substancesInToleranceWindows = Set(toleranceWindows.map({$0.substanceName}))
        let substancesWithoutToleranceWindows = substancesInIngestions.subtracting(substancesInToleranceWindows)
        substancesInIngestionsButNotChart = Array(substancesWithoutToleranceWindows)
    }

    private func getSortedSubstanceCountsLast30Days() -> [SubstanceCount] {
        let last30Days = experiences.prefix { exp in
            Calendar.current.numberOfDaysBetween(exp.sortDateUnwrapped, and: Date()) <= 30
        }
        return getSortedSubstanceCounts(for: last30Days)
    }

    private func getSortedSubstanceCountsLast12Months() -> [SubstanceCount] {
        let last12Months = experiences.prefix { exp in
            Calendar.current.numberOfMonthsBetween(exp.sortDateUnwrapped, and: Date()) <= 12
        }
        return getSortedSubstanceCounts(for: last12Months)
    }

    private func getSortedSubstanceCountsYears() -> [SubstanceCount] {
        return getSortedSubstanceCounts(for: experiences)
    }

    private func getSortedSubstanceCounts(for experiences: any Sequence<Experience>) -> [SubstanceCount] {
        let substanceNameOccurances = experiences.flatMap { experience in
            experience.myIngestionsSorted.map { ingestion in
                ingestion.substanceNameUnwrapped
            }.uniqued()
        }
        var countDict: [String: Int] = [:]
        for substanceName in substanceNameOccurances {
            countDict[substanceName, default: 0] += 1
        }
        return countDict.map { (substanceName: String, count: Int) in
            return SubstanceCount(
                substanceName: substanceName,
                experienceCount: count
            )
        }.sorted { count1, count2 in
            count1.experienceCount > count2.experienceCount
        }
    }

    private func getExperienceCountsLast30Days() -> [SubstanceExperienceCountForDay] {
        let experiencesLast30Days = experiences.prefix { ex in
            Calendar.current.numberOfDaysBetween(ex.sortDateUnwrapped, and: Date()) <= 30
        }
        let ungroupedResult = experiencesLast30Days.flatMap { ex in
            let distinctSubstanceNames = ex.myIngestionsSorted.map { $0.substanceNameUnwrapped }.uniqued()
            return distinctSubstanceNames.map { substanceName in
                SubstanceExperienceCountForDay(
                    day: ex.sortDateUnwrapped,
                    substanceName: substanceName,
                    experienceCount: 1/Double(distinctSubstanceNames.count)
                )
            }
        }
        return Dictionary(grouping: ungroupedResult) { result in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: result.day)
            var substanceYearMonthDay = result.substanceName
            if let year = components.year, let month = components.month, let day = components.day {
                substanceYearMonthDay += String(year) + String(month) + String(day)
            }
            return substanceYearMonthDay
        }.compactMap { (key: _, matchesForSameDay: [SubstanceExperienceCountForDay]) in
            guard let first = matchesForSameDay.first else {return nil}
            let experienceCount = matchesForSameDay.map { $0.experienceCount }.reduce(0, +)
            return SubstanceExperienceCountForDay(
                day: first.day,
                substanceName: first.substanceName,
                experienceCount: experienceCount
            )
        }
    }

    private func getExperienceCountsLast12Months() -> [SubstanceExperienceCountForMonth] {
        let experiencesLast12Months = experiences.prefix { ex in
            Calendar.current.numberOfMonthsBetween(ex.sortDateUnwrapped, and: Date()) <= 12
        }
        let ungroupedResult = experiencesLast12Months.flatMap { ex in
            let distinctSubstanceNames = ex.myIngestionsSorted.map { $0.substanceNameUnwrapped }.uniqued()
            return distinctSubstanceNames.map { substanceName in
                SubstanceExperienceCountForMonth(
                    month: ex.sortDateUnwrapped,
                    substanceName: substanceName,
                    experienceCount: 1/Double(distinctSubstanceNames.count)
                )
            }
        }
        return Dictionary(grouping: ungroupedResult) { result in
            let components = Calendar.current.dateComponents([.year, .month], from: result.month)
            var substanceYearMonth = result.substanceName
            if let year = components.year, let month = components.month {
                substanceYearMonth += String(year) + String(month)
            }
            return substanceYearMonth
        }.compactMap { (key: _, matchesForSameMonth: [SubstanceExperienceCountForMonth]) in
            guard let first = matchesForSameMonth.first else {return nil}
            let experienceCount = matchesForSameMonth.map { $0.experienceCount }.reduce(0, +)
            return SubstanceExperienceCountForMonth(
                month: first.month,
                substanceName: first.substanceName,
                experienceCount: experienceCount
            )
        }
    }

    private func getExperienceCountsYears() -> [SubstanceExperienceCountForYear] {
        let ungroupedResult = experiences.flatMap { ex in
            let distinctSubstanceNames = ex.myIngestionsSorted.map { $0.substanceNameUnwrapped }.uniqued()
            return distinctSubstanceNames.map { substanceName in
                SubstanceExperienceCountForYear(
                    year: ex.sortDateUnwrapped,
                    substanceName: substanceName,
                    experienceCount: 1/Double(distinctSubstanceNames.count)
                )
            }
        }
        return Dictionary(grouping: ungroupedResult) { result in
            let components = Calendar.current.dateComponents([.year], from: result.year)
            var substanceYear = result.substanceName
            if let year = components.year {
                substanceYear += String(year)
            }
            return substanceYear
        }.compactMap { (key: _, matchesForSameYear: [SubstanceExperienceCountForYear]) in
            guard let first = matchesForSameYear.first else {return nil}
            let experienceCount = matchesForSameYear.map { $0.experienceCount }.reduce(0, +)
            return SubstanceExperienceCountForYear(
                year: first.year,
                substanceName: first.substanceName,
                experienceCount: experienceCount
            )
        }
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day!
    }

    func numberOfMonthsBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfMonths = dateComponents([.month], from: fromDate, to: toDate)
        return numberOfMonths.month!
    }
}

@available(iOS 16, *)
struct StatsScreenContent: View {

    let experienceData: ExperienceData
    let substanceData: SubstanceData
    let toleranceWindows: [ToleranceWindow]
    let substancesInIngestionsButNotChart: [String]
    let isEyeOpen: Bool

    var body: some View {
        List {
            if isEyeOpen {
                Section {
                    NavigationLink {
                        ToleranceChartScreen()
                    } label: {
                        ToleranceChartOverView(toleranceWindows: toleranceWindows)
                    }
                } footer: {
                    if !substancesInIngestionsButNotChart.isEmpty {
                        Text("Excluding ") + Text(substancesInIngestionsButNotChart, format: .list(type: .and))
                    }
                }
            }
            Section {
                NavigationLink {
                    ExperienceDetailsScreen(experienceData: experienceData)
                } label: {
                    ExperienceOverview(experienceData: experienceData)
                }
            }
            Section {
                NavigationLink {
                    SubstanceDetailsScreen(substanceData: substanceData)
                } label: {
                    SubstanceOverview(substanceData: substanceData)
                }
            }
        }.navigationTitle("My Stats")
    }
}

@available(iOS 16, *)
struct StatsScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatsScreenContent(
                experienceData: .mock1,
                substanceData: .mock1,
                toleranceWindows: ToleranceChartPreviewDataProvider.mock1,
                substancesInIngestionsButNotChart: ["2C-B", "DMT"],
                isEyeOpen: true
            )
        }
    }
}
