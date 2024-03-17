// Copyright (c) 2024. Isaak Hanimann.
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

import SwiftUI
import Charts

struct DosageStatYearChart: View {

    let years: [YearDosage]
    let substanceName: String
    let substanceColor: SubstanceColor
    let unit: String
    let isAverageShown: Bool

    var numberOfYears: Int {
        let calendar = Calendar.current
        let firstYearDate = years.sorted { lhs, rhs in
            lhs.year < rhs.year
        }.first?.year ?? Date.now
        let firstYear = calendar.dateComponents([.year], from: firstYearDate).year ?? 0
        let nowYear = calendar.dateComponents([.year], from: .now).year ?? 0
        return nowYear - firstYear + 1
    }

    var averageDosage: Double {
        let sum = years.map({$0.dosage}).reduce(0, +)
        if numberOfYears > 0 {
            return sum/Double(numberOfYears)
        } else {
            return 0
        }
    }

    var body: some View {
        if !years.isEmpty {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Dosage by year")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("All Years")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                Chart(years, id: \.year) {
                    if isAverageShown {
                        BarMark(
                            x: .value("Year", $0.year, unit: .year),
                            y: .value("Dosage", $0.dosage)
                        )
                        .foregroundStyle(.gray.opacity(0.3))
                        RuleMark(
                            y: .value("Average", averageDosage)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Average: \(averageDosage.asRoundedReadableString) \(unit) per year in last \(numberOfYears) years")
                                .font(.body.bold())
                                .foregroundStyle(.blue)
                        }
                    } else {
                        BarMark(
                            x: .value("Year", $0.year, unit: .year),
                            y: .value("Dosage", $0.dosage)
                        )
                        .foregroundStyle(substanceColor.swiftUIColor)
                    }
                }.chartYAxisLabel("Dosage in \(unit)")
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .year, count: 1)) { value in
                            AxisValueLabel(format: .dateTime.year())
                        }
                    }
                    .frame(height: 240)
            }
        } else {
            Text("No \(substanceName) ingestions").foregroundStyle(.secondary)
        }
    }
}

private let oneYear: TimeInterval = 365*24*60*60

#Preview {
    DosageStatYearChart(
        years: [
            YearDosage(year: .now.addingTimeInterval(-oneYear), dosage: 20),
            YearDosage(year: .now.addingTimeInterval(-1*oneYear), dosage: 35),
            YearDosage(year: .now.addingTimeInterval(-3*oneYear), dosage: 70),
            YearDosage(year: .now.addingTimeInterval(-4*oneYear), dosage: 40)
        ],
        substanceName: "LSD",
        substanceColor: .blue,
        unit: "ug",
        isAverageShown: true
    )
}
