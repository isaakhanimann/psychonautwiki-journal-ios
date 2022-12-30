//
//  ExperienceDetails.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import Charts
import SwiftUI


@available(iOS 16, *)
struct ExperienceDetails: View {

    let experienceData: ExperienceData
    @State private var timeRange: TimeRange = .last12Months
    @State private var isShowingMonthlyAverageLine: Bool = false
    @State private var isShowingYearlyAverageLine: Bool = false

    var body: some View {
        List {
            VStack(alignment: .leading) {
                TimeRangePicker(value: $timeRange)
                    .padding(.bottom)
                let chartHeight: CGFloat = 240
                switch timeRange {
                case .last30Days:
                    Text("Total Experiences")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("\(experienceData.last30DaysTotal, format: .number) Experiences")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    DailyExperienceChart(experienceData: experienceData)
                        .frame(height: chartHeight)
                case .last12Months:
                    MonthlyExperienceChart(
                        experienceData: experienceData,
                        isShowingMonthlyAverageLine: isShowingMonthlyAverageLine
                    )
                case .years:
                    Text("Total Experiences")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("\(experienceData.yearsTotal, format: .number) Experiences")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    YearlyExperienceChart(
                        experienceData: experienceData,
                        isShowingYearlyAverageLine: isShowingYearlyAverageLine
                    )
                    .frame(height: chartHeight)
                }
            }
            .listRowSeparator(.hidden)
            if timeRange == .last12Months {
                Section("Options") {
                    Toggle("Show Monthly Average", isOn: $isShowingMonthlyAverageLine).tint(.accentColor)
                }
            } else if timeRange == .years {
                Section("Options") {
                    Toggle("Show Yearly Average", isOn: $isShowingYearlyAverageLine).tint(.accentColor)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Total Experiences")
    }
}

@available(iOS 16, *)
struct ExperienceDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExperienceDetails(experienceData: .mock1)
        }
    }
}
