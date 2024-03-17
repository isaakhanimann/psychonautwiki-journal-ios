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

struct DosageStatMonthChart: View {

    let last12Months: [MonthDosage]
    let substanceName: String
    let substanceColor: SubstanceColor
    let unit: String
    let isAverageShown: Bool

    var averageDosage: Double {
        let sum = last12Months.map({$0.dosage}).reduce(0, +)
        return sum/12
    }


    var body: some View {
        if !last12Months.isEmpty {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Dosage by month")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Last 12 Months")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                Chart(last12Months, id: \.month) {
                    if isAverageShown {
                        BarMark(
                            x: .value("Month", $0.month, unit: .month),
                            y: .value("Dosage", $0.dosage)
                        )
                        .foregroundStyle(.gray.opacity(0.3))
                        RuleMark(
                            y: .value("Average", averageDosage)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Average: \(averageDosage.asRoundedReadableString) \(unit) per month")
                                .font(.body.bold())
                                .foregroundStyle(.blue)
                        }
                    } else {
                        BarMark(
                            x: .value("Month", $0.month, unit: .month),
                            y: .value("Dosage", $0.dosage)
                        )
                        .foregroundStyle(substanceColor.swiftUIColor)
                    }
                }.chartYAxisLabel("Dosage in \(unit)")
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month, count: 1)) { value in
                            AxisValueLabel(format: .dateTime.month())
                        }
                    }
                    .frame(height: 240)
            }
        } else {
            Text("No \(substanceName) ingestions in the last 12 months").foregroundStyle(.secondary)
        }
    }
}

private let oneMonth: TimeInterval = 30*24*60*60

#Preview {
    DosageStatMonthChart(
        last12Months: [
            MonthDosage(month: .now.addingTimeInterval(-2*oneMonth), dosage: 20),
            MonthDosage(month: .now.addingTimeInterval(-3*oneMonth), dosage: 35),
            MonthDosage(month: .now.addingTimeInterval(-6*oneMonth), dosage: 70),
            MonthDosage(month: .now.addingTimeInterval(-7*oneMonth), dosage: 40),
            MonthDosage(month: .now.addingTimeInterval(-11*oneMonth), dosage: 20),
        ],
        substanceName: "LSD",
        substanceColor: .blue,
        unit: "ug",
        isAverageShown: true
    )
}
