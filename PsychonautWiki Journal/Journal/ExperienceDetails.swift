//
//  ExperienceDetails.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import Charts
import SwiftUI

@available(iOS 16, *)
struct DailyExperienceChart: View {

    let experienceData: ExperienceData

    var body: some View {
        Chart {
            ForEach(experienceData.last30Days) {
                BarMark(
                    x: .value("Day", $0.day, unit: .day),
                    y: .value("Experiences", $0.experienceCount)
                )
                .foregroundStyle(by: .value("Substance", $0.substanceName))
            }
        }
        .chartForegroundStyleScale(mapping: experienceData.colorMapping)
    }
}

@available(iOS 16, *)
struct MonthlyExperienceChart: View {

    let experienceData: ExperienceData
    let isShowingMonthlyAverageLine: Bool

    var body: some View {
        Chart(experienceData.last12Months, id: \.month) {
            if isShowingMonthlyAverageLine {
                BarMark(
                    x: .value("Month", $0.month, unit: .month),
                    y: .value("Experiences", $0.experienceCount)
                )
                .foregroundStyle(.gray.opacity(0.3))
                RuleMark(
                    y: .value("Average", experienceData.monthlyAverage)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .annotation(position: .top, alignment: .leading) {
                    Text("Average: \(experienceData.monthlyAverage, format: .number)")
                        .font(.body.bold())
                        .foregroundStyle(.blue)
                }
            } else {
                BarMark(
                    x: .value("Month", $0.month, unit: .month),
                    y: .value("Experiences", $0.experienceCount)
                )
                .foregroundStyle(by: .value("Substance", $0.substanceName))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartForegroundStyleScale(mapping: experienceData.colorMapping)
    }
}

@available(iOS 16, *)
struct YearlyExperienceChart: View {

    let experienceData: ExperienceData
    let isShowingYearlyAverageLine: Bool

    var body: some View {
        Chart(experienceData.years, id: \.year) {
            if isShowingYearlyAverageLine {
                BarMark(
                    x: .value("Year", $0.year, unit: .year),
                    y: .value("Experiences", $0.experienceCount)
                )
                .foregroundStyle(.gray.opacity(0.3))
                RuleMark(
                    y: .value("Average", experienceData.yearlyAverage)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .annotation(position: .top, alignment: .leading) {
                    Text("Average: \(experienceData.yearlyAverage, format: .number)")
                        .font(.body.bold())
                        .foregroundStyle(.blue)
                }
            } else {
                BarMark(
                    x: .value("Year", $0.year, unit: .year),
                    y: .value("Experiences", $0.experienceCount)
                )
                .foregroundStyle(by: .value("Substance", $0.substanceName))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .year)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.year(), centered: true)
            }
        }
        .chartForegroundStyleScale(mapping: experienceData.colorMapping)
    }
}

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
                Text("Total Experiences")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                let chartHeight: CGFloat = 240
                switch timeRange {
                case .last30Days:
                    Text("\(experienceData.last30DaysTotal, format: .number) Experiences")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    DailyExperienceChart(experienceData: experienceData)
                        .frame(height: chartHeight)
                case .last12Months:
                    Text("\(experienceData.last12MonthsTotal, format: .number) Experiences")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    MonthlyExperienceChart(
                        experienceData: experienceData,
                        isShowingMonthlyAverageLine: isShowingMonthlyAverageLine
                    )
                    .frame(height: chartHeight)
                case .years:
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
                    Toggle("Show Monthly Average", isOn: $isShowingMonthlyAverageLine)
                }
            } else if timeRange == .years {
                Section("Options") {
                    Toggle("Show Yearly Average", isOn: $isShowingYearlyAverageLine)
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
