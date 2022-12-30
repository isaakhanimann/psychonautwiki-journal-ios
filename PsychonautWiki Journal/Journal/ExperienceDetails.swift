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
        .chartLegend(position: .bottom, alignment: .leading)
    }
}

@available(iOS 16, *)
struct MonthlyExperienceChart: View {

    let experienceData: ExperienceData
    let isShowingMonthlyAverageLine: Bool
    @Binding var selectedElement: SubstanceExperienceCountForMonth?

    func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> SubstanceExperienceCountForMonth? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int? = nil
            for experienceDataIndex in experienceData.last12Months.indices {
                let nthExperienceCountDistance = experienceData.last12Months[experienceDataIndex].month.distance(to: date)
                if abs(nthExperienceCountDistance) < minDistance {
                    minDistance = abs(nthExperienceCountDistance)
                    index = experienceDataIndex
                }
            }
            if let index = index {
                return experienceData.last12Months[index]
            }
        }
        return nil
    }


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
        .chartLegend(position: .bottom, alignment: .leading)
        .chartOverlay { proxy in
            GeometryReader { nthGeometryItem in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                let element = findElement(location: value.location, proxy: proxy, geometry: nthGeometryItem)
                                if selectedElement?.month == element?.month {
                                    // If tapping the same element, clear the selection.
                                    selectedElement = nil
                                } else {
                                    selectedElement = element
                                }
                            }
                            .exclusively(
                                before: DragGesture()
                                    .onChanged { value in
                                        selectedElement = findElement(location: value.location, proxy: proxy, geometry: nthGeometryItem)
                                    }
                            )
                    )
            }
        }
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
        .chartLegend(position: .bottom, alignment: .leading)
    }
}

@available(iOS 16, *)
struct ExperienceDetails: View {

    let experienceData: ExperienceData
    @State private var timeRange: TimeRange = .last12Months
    @State private var isShowingMonthlyAverageLine: Bool = false
    @State private var isShowingYearlyAverageLine: Bool = false

    @State private var selectedElement: SubstanceExperienceCountForMonth? = nil
    @Environment(\.layoutDirection) var layoutDirection

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
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Total Experiences")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text("\(experienceData.last12MonthsTotal, format: .number) Experiences")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }.opacity(selectedElement == nil ? 1 : 0)
                        MonthlyExperienceChart(
                            experienceData: experienceData,
                            isShowingMonthlyAverageLine: isShowingMonthlyAverageLine,
                            selectedElement: $selectedElement
                        )
                        .frame(height: chartHeight)
                    }
                    .chartBackground { proxy in
                        ZStack(alignment: .topLeading) {
                            GeometryReader { nthGeoItem in
                                if let selectedElement = selectedElement {
                                    let dateInterval = Calendar.current.dateInterval(of: .month, for: selectedElement.month)!
                                    let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
                                    let startPositionX2 = proxy.position(forX: dateInterval.end) ?? 0
                                    let midStartPositionX = (startPositionX1 + startPositionX2) / 2 + nthGeoItem[proxy.plotAreaFrame].origin.x
                                    let lineX = layoutDirection == .rightToLeft ? nthGeoItem.size.width - midStartPositionX : midStartPositionX
                                    let lineHeight = nthGeoItem[proxy.plotAreaFrame].maxY
                                    let boxWidth: CGFloat = 150
                                    let boxOffset = max(0, min(nthGeoItem.size.width - boxWidth, lineX - boxWidth / 2))
                                    Rectangle()
                                        .fill(.quaternary)
                                        .frame(width: 2, height: lineHeight)
                                        .position(x: lineX, y: lineHeight / 2)
                                    Text("\(selectedElement.month, format: .dateTime.year().month())")
                                        .font(.title2.bold())
                                        .frame(width: boxWidth, alignment: .center)
                                        .foregroundColor(.primary)
                                        .background {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.background)
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(.quaternary.opacity(0.7))
                                            }
                                            .padding([.leading, .trailing], -8)
                                            .padding([.top, .bottom], -4)
                                        }
                                        .offset(x: boxOffset)
                                }
                            }
                        }
                    }
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
