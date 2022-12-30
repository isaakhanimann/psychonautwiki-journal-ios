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

    @State private var experienceData: ExperienceData? = nil
    @State private var ingestionData: IngestionData? = nil

    var body: some View {
        if let experienceData {
            List {
                Section {
                    NavigationLink {
                        ExperienceDetails(experienceData: experienceData)
                    } label: {
                        ExperienceOverview(experienceData: experienceData)
                    }
                }
//                Section {
//                    NavigationLink {
//                        IngestionDetails(ingestionData: ingestionData)
//                    } label: {
//                        IngestionOverview(ingestionData: ingestionData)
//                    }
//                }
            }.navigationTitle("Stats")
        } else {
            ProgressView().task {
                experienceData = ExperienceData(
                    last30Days: getLast30Days(),
                    last12Months: getLast12Months(),
                    colorMapping: { substanceName in
                        getColor(for: substanceName).swiftUIColor
                    }
                )
            }
        }
    }

    private func getLast30Days() -> [SubstanceExperienceCountForDay] {
        let experiencesLast30Days = experiences.prefix { ex in
            Calendar.current.numberOfDaysBetween(ex.sortDateUnwrapped, and: Date()) < 30
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
        let last30Days: [SubstanceExperienceCountForDay] = Dictionary(grouping: ungroupedResult) { result in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: result.day)
            var substanceYearMonth = result.substanceName
            if let year = components.year, let month = components.month, let day = components.day {
                substanceYearMonth += String(year) + String(month) + String(day)
            }
            return substanceYearMonth
        }.compactMap { (key: _, matchesForSameDay: [SubstanceExperienceCountForDay]) in
            guard let first = matchesForSameDay.first else {return nil}
            let experienceCount = matchesForSameDay.map { $0.experienceCount }.reduce(0, +)
            return SubstanceExperienceCountForDay(
                day: first.day,
                substanceName: first.substanceName,
                experienceCount: experienceCount
            )
        }
        return last30Days
    }

    private func getLast12Months() -> [SubstanceExperienceCountForMonth] {
        let experiencesLast12Months = experiences.prefix { ex in
            Calendar.current.numberOfMonthsBetween(ex.sortDateUnwrapped, and: Date()) < 12
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
        let last12Months: [SubstanceExperienceCountForMonth] = Dictionary(grouping: ungroupedResult) { result in
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
        return last12Months
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

    var body: some View {
        List {
            Section {
                NavigationLink {
                    ExperienceDetails(experienceData: experienceData)
                } label: {
                    ExperienceOverview(experienceData: experienceData)
                }
            }
            Section {
                NavigationLink {
                    IngestionDetails(ingestionData: ingestionData)
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
                ingestionData: .mock1
            )
        }
    }
}
