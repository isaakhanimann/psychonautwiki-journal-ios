//
//  DailyExperienceChart.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 30.12.22.
//

import SwiftUI
import Charts

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
        .chartLegend(position: .bottom, alignment: .leading)
    }
}

@available(iOS 16, *)
struct DailyExperienceChart_Previews: PreviewProvider {
    static var previews: some View {
        DailyExperienceChart(experienceData: .mock1)
    }
}
