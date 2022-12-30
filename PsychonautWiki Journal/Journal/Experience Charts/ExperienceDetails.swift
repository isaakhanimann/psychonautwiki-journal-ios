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
                    DailyExperienceChart(
                        experienceData: experienceData,
                        chartHeight: chartHeight
                    )
                case .last12Months:
                    MonthlyExperienceChart(
                        experienceData: experienceData,
                        isShowingMonthlyAverageLine: isShowingMonthlyAverageLine,
                        chartHeight: chartHeight
                    )
                case .years:
                    YearlyExperienceChart(
                        experienceData: experienceData,
                        isShowingYearlyAverageLine: isShowingYearlyAverageLine,
                        chartHeight: chartHeight
                    )
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
