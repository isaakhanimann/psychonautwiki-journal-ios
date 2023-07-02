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
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false)]
    ) var experiences: FetchedResults<Experience>

    @FetchRequest(
        sortDescriptors: []
    ) var substanceCompanions: FetchedResults<SubstanceCompanion>

    @State private var experienceData: ExperienceData? = nil
    @State private var ingestionData: IngestionData? = nil
    @State private var toleranceWindows: [ToleranceWindow] = []

    var body: some View {
        NavigationView {
            Group {
                if let experienceData, let ingestionData {
                    StatsScreenContent(
                        experienceData: experienceData,
                        ingestionData: ingestionData,
                        toleranceWindows: toleranceWindows
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
        ingestionData = IngestionData(
            last30Days: getSortedIngestionCountsLast30Days(),
            last12Months: getSortedIngestionCountsLast12Months(),
            years: getSortedIngestionCountsYears(),
            colorMapping: { substanceName in
                getColor(for: substanceName).swiftUIColor
            }
        )
        let ingestionsLast90Days = ingestions.prefix { ing in
            Calendar.current.numberOfDaysBetween(ing.timeUnwrapped, and: Date()) <= 90
        }
        toleranceWindows = ToleranceChartCalculator.getToleranceWindows(
            from: Array(ingestionsLast90Days),
            substanceCompanions: Array(substanceCompanions)
        )

    }

    private func getSortedIngestionCountsLast30Days() -> [IngestionCount] {
        let ingestionsLast30Days = ingestions.prefix { ing in
            Calendar.current.numberOfDaysBetween(ing.timeUnwrapped, and: Date()) <= 30
        }
        return getSortedIngestionCounts(for: ingestionsLast30Days)

    }

    private func getSortedIngestionCountsLast12Months() -> [IngestionCount] {
        let ingestionsLast12Months = ingestions.prefix { ing in
            Calendar.current.numberOfMonthsBetween(ing.timeUnwrapped, and: Date()) <= 12
        }
        return getSortedIngestionCounts(for: ingestionsLast12Months)
    }

    private func getSortedIngestionCountsYears() -> [IngestionCount] {
        return getSortedIngestionCounts(for: ingestions)
    }

    private func getSortedIngestionCounts(for ingestions: any Sequence<Ingestion>) -> [IngestionCount] {
        return Dictionary(grouping: ingestions) { ing in
            ing.substanceNameUnwrapped
        }.compactMap { (substanceName: String, ingestionsSameSubstance: [Slice<FetchedResults<Ingestion>>.Element]) in
            return IngestionCount(
                substanceName: substanceName,
                ingestionCount: ingestionsSameSubstance.count
            )
        }.sorted { count1, count2 in
            count1.ingestionCount > count2.ingestionCount
        }
    }

    private func getExperienceCountsLast30Days() -> [SubstanceExperienceCountForDay] {
        let experiencesLast30Days = experiences.prefix { ex in
            Calendar.current.numberOfDaysBetween(ex.sortDateUnwrapped, and: Date()) <= 30
        }
        let ungroupedResult = experiencesLast30Days.flatMap { ex in
            let distinctSubstanceNames = ex.sortedIngestionsUnwrapped.map { $0.substanceNameUnwrapped }.uniqued()
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
            let distinctSubstanceNames = ex.sortedIngestionsUnwrapped.map { $0.substanceNameUnwrapped }.uniqued()
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
            let distinctSubstanceNames = ex.sortedIngestionsUnwrapped.map { $0.substanceNameUnwrapped }.uniqued()
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
    let ingestionData: IngestionData
    let toleranceWindows: [ToleranceWindow]

    var body: some View {
        List {
            Section {
                NavigationLink {
                    ToleranceChartScreen()
                } label: {
                    ToleranceChartOverView(toleranceWindows: toleranceWindows)
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
                    IngestionDetailsScreen(ingestionData: ingestionData)
                } label: {
                    IngestionOverview(ingestionData: ingestionData)
                }
            }
        }.navigationTitle("Stats")
    }
}

@available(iOS 16, *)
struct StatsScreenContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatsScreenContent(
                experienceData: .mock1,
                ingestionData: .mock1,
                toleranceWindows: [
                    ToleranceWindow(substanceName: "MDMA",
                                    start: getDate(year: 2023, month: 2, day: 1)!,
                                    end: getDate(year: 2023, month: 4, day: 1)!,
                                    toleranceType: .full,
                                    substanceColor: .pink),
                    ToleranceWindow(substanceName: "MDMA",
                                    start: getDate(year: 2023, month: 4, day: 1)!,
                                    end: getDate(year: 2023, month: 5, day: 1)!,
                                    toleranceType: .half,
                                    substanceColor: .pink),
                    ToleranceWindow(substanceName: "Ketamine",
                                    start: getDate(year: 2023, month: 2, day: 10)!,
                                    end: getDate(year: 2023, month: 2, day: 20)!,
                                    toleranceType: .full,
                                    substanceColor: .blue),
                    ToleranceWindow(substanceName: "Ketamine",
                                    start: getDate(year: 2023, month: 2, day: 20)!,
                                    end: getDate(year: 2023, month: 2, day: 30)!,
                                    toleranceType: .half,
                                    substanceColor: .blue)
                    ]
            )
        }
    }
}
