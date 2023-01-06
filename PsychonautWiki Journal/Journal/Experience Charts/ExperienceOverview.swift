//
//  ExperienceOverview.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import Charts
import SwiftUI

@available(iOS 16, *)
struct ExperienceOverviewChart: View {

    let experienceData: ExperienceData

    var body: some View {
        Chart(experienceData.last12Months, id: \.month) {
            BarMark(
                x: .value("Month", $0.month, unit: .month),
                y: .value("Experiences", $0.experienceCount)
            )
            .foregroundStyle(by: .value("Substance", $0.substanceName))
        }
        .chartForegroundStyleScale(mapping: experienceData.colorMapping)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

@available(iOS 16, *)
struct ExperienceOverview: View {

    let experienceData: ExperienceData

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Experiences Last 12 Months")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("\(experienceData.last12MonthsTotal, format: .number) Experiences")
                .font(.title2.bold())
            ExperienceOverviewChart(experienceData: experienceData)
                .frame(height: 100)
        }
    }
}

@available(iOS 16, *)
struct ExperienceOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceOverview(experienceData: .mock1)
            .padding()
    }
}
