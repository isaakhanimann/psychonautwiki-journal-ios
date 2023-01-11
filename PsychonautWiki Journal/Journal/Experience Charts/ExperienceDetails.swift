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
