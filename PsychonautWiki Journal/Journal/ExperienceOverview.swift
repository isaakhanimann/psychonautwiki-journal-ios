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
    var body: some View {
        Chart(ExperienceData.last30Days, id: \.day) {
            BarMark(
                x: .value("Day", $0.day, unit: .day),
                y: .value("Experiences", $0.experienceCount)
            )
            .foregroundStyle(by: .value("Substance", $0.substanceName))
        }
        .chartForegroundStyleScale(ExperienceData.last30DaysColors)
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

@available(iOS 16, *)
struct ExperienceOverview: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Experiences")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("\(ExperienceData.last30DaysTotal, format: .number) Experiences")
                .font(.title2.bold())
            ExperienceOverviewChart()
                .frame(height: 100)
        }
    }
}

@available(iOS 16, *)
struct ExperienceOverview_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceOverview()
            .padding()
    }
}