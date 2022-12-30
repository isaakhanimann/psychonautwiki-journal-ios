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

    var body: some View {
        Chart {
            ForEach(ExperienceData.last30Days, id: \.day) {
                BarMark(
                    x: .value("Day", $0.day, unit: .day),
                    y: .value("Experiences", $0.experienceCount)
                )
                .foregroundStyle(by: .value("Substance", $0.substanceName))
            }
        }
        .chartForegroundStyleScale(ExperienceData.substanceColors)
    }
}

@available(iOS 16, *)
struct MonthlyExperienceChart: View {
    let showAverageLine: Bool

    var body: some View {
        Chart(ExperienceData.last12Months, id: \.month) {
            if showAverageLine {
                BarMark(
                    x: .value("Month", $0.month, unit: .month),
                    y: .value("Experiences", $0.experienceCount)
                )
                .foregroundStyle(.gray.opacity(0.3))
                RuleMark(
                    y: .value("Average", ExperienceData.monthlyAverage)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .annotation(position: .top, alignment: .leading) {
                    Text("Average: \(ExperienceData.monthlyAverage, format: .number)")
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
        .chartForegroundStyleScale(ExperienceData.substanceColors)
    }
}

@available(iOS 16, *)
struct ExperienceDetails: View {
    @State private var timeRange: TimeRange = .last30Days
    @State private var showAverageLine: Bool = false

    var body: some View {
        List {
            VStack(alignment: .leading) {
                TimeRangePicker(value: $timeRange)
                    .padding(.bottom)

                Text("Total Experiences")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                switch timeRange {
                case .last30Days:
                    Text("\(ExperienceData.last30DaysTotal, format: .number) Experiences")
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    DailyExperienceChart()
                        .frame(height: 240)
                case .last12Months:
                    Text("\(ExperienceData.last12MonthsTotal, format: .number) Experiences")
                        .font(.title2.bold())
                        .foregroundColor(.primary)

                    MonthlyExperienceChart(showAverageLine: showAverageLine)
                        .frame(height: 240)
                }
            }
            .listRowSeparator(.hidden)

            Section("Options") {
                if timeRange == .last12Months {
                    Toggle("Show Monthly Average", isOn: $showAverageLine)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitle("Total Sales", displayMode: .inline)
    }
}

@available(iOS 16, *)
struct ExperienceDetails_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceDetails()
    }
}
