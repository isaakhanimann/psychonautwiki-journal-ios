//
//  YearlyExperienceChart.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import SwiftUI
import Charts

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
        .chartLegend(position: .bottom, alignment: .leading)
    }
}

@available(iOS 16, *)
struct YearlyExperienceChart_Previews: PreviewProvider {
    static var previews: some View {
        YearlyExperienceChart(
            experienceData: .mock1,
            isShowingYearlyAverageLine: false
        )
    }
}
