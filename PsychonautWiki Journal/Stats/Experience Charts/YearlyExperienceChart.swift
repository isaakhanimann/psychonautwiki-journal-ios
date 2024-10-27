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

struct YearlyExperienceChart: View {
    let experienceData: ExperienceData
    let isShowingYearlyAverageLine: Bool
    let colorMapping: (String) -> Color
    var chartHeight: CGFloat = 240
    @State private var selectedElement: SubstanceExperienceCountForYear?
    @Environment(\.layoutDirection) var layoutDirection

    func findElement(
        location: CGPoint,
        proxy: ChartProxy,
        geometry: GeometryProxy
    ) -> SubstanceExperienceCountForYear? {
        let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        if let date = proxy.value(atX: relativeXPosition) as Date? {
            // Find the closest date element.
            var minDistance: TimeInterval = .infinity
            var index: Int?
            for experienceDataIndex in experienceData.years.indices {
                let nthExperienceCountDistance = experienceData.years[experienceDataIndex].year.distance(to: date)
                if abs(nthExperienceCountDistance) < minDistance {
                    minDistance = abs(nthExperienceCountDistance)
                    index = experienceDataIndex
                }
            }
            if let index = index {
                return experienceData.years[index]
            }
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Total Experiences")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("\(experienceData.yearsTotal, format: .number) Experiences")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
            }.opacity(selectedElement == nil ? 1 : 0)
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
                        Text("Average: \(experienceData.yearlyAverage.asRoundedReadableString)")
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
            .chartForegroundStyleScale(mapping: colorMapping)
            .chartLegend(position: .bottom, alignment: .leading)
            .chartOverlay { proxy in
                GeometryReader { nthGeometryItem in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let element = findElement(
                                        location: value.location,
                                        proxy: proxy,
                                        geometry: nthGeometryItem
                                    )
                                    if selectedElement?.year == element?.year {
                                        // If tapping the same element, clear the selection.
                                        selectedElement = nil
                                    } else {
                                        selectedElement = element
                                    }
                                }
                                .exclusively(
                                    before: DragGesture(minimumDistance: minimumDistanceForDetectingDragGesture)
                                        .onChanged { value in
                                            selectedElement = findElement(location: value.location, proxy: proxy, geometry: nthGeometryItem)
                                        }
                                )
                        )
                }
            }
            .frame(height: chartHeight)
        }
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { nthGeoItem in
                    if let selectedElement = selectedElement,
                       let dateInterval = Calendar.current.dateInterval(of: .year, for: selectedElement.year) {
                        let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
                        let startPositionX2 = proxy.position(forX: dateInterval.end) ?? 0
                        let midStartPositionX = (startPositionX1 + startPositionX2) / 2 + nthGeoItem[proxy.plotAreaFrame].origin.x
                        let lineX = layoutDirection == .rightToLeft ? nthGeoItem.size.width - midStartPositionX : midStartPositionX
                        let lineHeight = nthGeoItem[proxy.plotAreaFrame].maxY
                        let boxWidth: CGFloat = 80
                        let boxOffset = max(0, min(nthGeoItem.size.width - boxWidth, lineX - boxWidth / 2))
                        Rectangle()
                            .fill(.quaternary)
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)
                        Text("\(selectedElement.year, format: .dateTime.year())")
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
    }
}

#Preview {
    List {
        YearlyExperienceChart(
            experienceData: .mock1,
            isShowingYearlyAverageLine: false,
            colorMapping: ExperienceData.mock1.colorMapping
        )
    }
}
