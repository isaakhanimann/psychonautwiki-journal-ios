// Copyright (c) 2023. Isaak Hanimann.
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

@available(iOS 16.0, *)
struct ToleranceChart: View {

    enum ToleranceType {
        case full, half
    }

    struct ToleranceWindow: Identifiable {
        let id = UUID()
        let substanceName: String
        let start: Date
        let end: Date
        let toleranceType: ToleranceType
    }


    let data: [ToleranceWindow] = [
        ToleranceWindow(substanceName: "MDMA",
                        start: getDate(year: 2023, month: 2, day: 1)!,
                        end: getDate(year: 2023, month: 3, day: 1)!,
                        toleranceType: .full),
        ToleranceWindow(substanceName: "MDMA",
                        start: getDate(year: 2023, month: 3, day: 1)!,
                        end: getDate(year: 2023, month: 4, day: 1)!,
                        toleranceType: .half),
        ToleranceWindow(substanceName: "MDMA",
                        start: getDate(year: 2023, month: 5, day: 1)!,
                        end: getDate(year: 2023, month: 6, day: 1)!,
                        toleranceType: .full),
        ToleranceWindow(substanceName: "Ketamine",
                        start: getDate(year: 2023, month: 2, day: 10)!,
                        end: getDate(year: 2023, month: 2, day: 20)!,
                        toleranceType: .full),
        ToleranceWindow(substanceName: "Ketamine",
                        start: getDate(year: 2023, month: 2, day: 20)!,
                        end: getDate(year: 2023, month: 2, day: 30)!,
                        toleranceType: .half)
        ]

    var body: some View {
        Chart(data) { window in
            BarMark(
                xStart: .value("Start Time", window.start),
                xEnd: .value("End Time", window.end),
                y: .value("Substance", window.substanceName)
            )
            .foregroundStyle(getColor(for: window))
        }
    }

    private func getColor(for toleranceWindow: ToleranceWindow) -> Color {
        var color = Color.pink
        if toleranceWindow.substanceName == "Ketamine" {
            color = .blue
        }
        if toleranceWindow.toleranceType == .half {
            return color.opacity(0.5)
        } else {
            return color
        }
    }

    private static func getDate(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents)
    }
}

@available(iOS 16.0, *)
struct ToleranceChart_Previews: PreviewProvider {
    static var previews: some View {
        ToleranceChart()
    }
}
