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
        if let experienceData, let ingestionData {
            StatsScreenContent(
                experienceData: experienceData,
                ingestionData: ingestionData
            )
        } else {
            ProgressView().task {
//                let experiencesLast30Days = experiences.prefix { ex in
//                    Calendar.current.numberOfDaysBetween(ex.sortDateUnwrapped, and: Date()) < 30
//                }
//                let experiencesLast12Months = experiences.prefix { ex in
//                    Calendar.current.numberOfMonthsBetween(ex.sortDateUnwrapped, and: Date()) < 12
//                }
//                let day: Date
//                let substanceName: String
//                let experienceCount: Double
//                let last30Days = experiencesLast30Days.flatMap { ex in
//                    // Todo: test what happens if 2 experiences are on same day
//                    let distinctSubstanceNames = ex.sortedIngestionsUnwrapped.map { $0.substanceNameUnwrapped }.uniqued()
//                    return distinctSubstanceNames.map { substanceName in
//                        ExperienceData.SubstanceExperienceCountForDay(
//                            day: ex.sortDateUnwrapped,
//                            substanceName: substanceName,
//                            experienceCount: 1/Double(distinctSubstanceNames.count)
//                        )
//                    }
//                }
//                let last30DaysColor: KeyValuePairs<String, Color> = experiencesLast30Days.flatMap { ex in
//                    let distinctSubstanceNames = ex.sortedIngestionsUnwrapped.map { $0.substanceNameUnwrapped }.uniqued()
//                    let substancesWithColors = distinctSubstanceNames.map { substanceName in
//                        [substanceName: (getColor(for: substanceName).swiftUIColor ?? Color.red)]
//                    }
//                    return substancesWithColors
//                }
//                print("hello")
//                experienceData = ExperienceData(
//                    last30Days: <#T##[ExperienceData.SubstanceExperienceCountForDay]#>,
//                    last30DaysColors: <#T##KeyValuePairs<String, Color>#>,
//                    last12Months: <#T##[ExperienceData.SubstanceExperienceCountForMonth]#>,
//                    last12MonthsColors: <#T##KeyValuePairs<String, Color>#>
//                )
            }
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
