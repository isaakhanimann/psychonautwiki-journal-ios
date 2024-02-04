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
import HorizonCalendar
import UIKit

struct JournalCalendarScreen: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)]
    ) var ingestions: FetchedResults<Ingestion>

    @State private var isFirstAppear = true

    init() {
        self.calendar = Calendar.current
        self.monthsLayout = MonthsLayout.vertical

        let thirtyYears: TimeInterval = 30*12*30*24*60*60
        let startDate = Date.now.addingTimeInterval(-thirtyYears)
        let halfYear: TimeInterval = 6*30*24*60*60
        let endDate = Date.now.addingTimeInterval(halfYear)
        visibleDateRange = startDate...endDate

        monthDateFormatter = DateFormatter()
        monthDateFormatter.calendar = calendar
        monthDateFormatter.locale = calendar.locale
        monthDateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "MMMM yyyy",
            options: 0,
            locale: calendar.locale ?? Locale.current)
    }

    var body: some View {
        CalendarViewRepresentable(
            calendar: calendar,
            visibleDateRange: visibleDateRange,
            monthsLayout: monthsLayout,
            dataDependency: ingestions,
            proxy: calendarViewProxy)
        .interMonthSpacing(24)
        .verticalDayMargin(8)
        .horizontalDayMargin(8)
        .monthHeaders { month in
            let monthHeaderText = monthDateFormatter.string(from: calendar.date(from: month.components)!)
            HStack {
                Text(monthHeaderText)
                    .font(.title2)
                Spacer()
            }
            .padding()
            .accessibilityAddTraits(.isHeader)
        }

        .days { dayComponents in
            DayView(dayComponents: dayComponents)
        }
        .onAppear {
            if isFirstAppear {
                calendarViewProxy.scrollToDay(
                    containing: Date.now,
                    scrollPosition: .lastFullyVisiblePosition(padding: 0),
                    animated: false)
                isFirstAppear = false
            }
        }
        .frame(maxWidth: 375, maxHeight: .infinity)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Today") {
                    calendarViewProxy.scrollToDay(
                        containing: Date.now,
                        scrollPosition: .lastFullyVisiblePosition(padding: 0),
                        animated: true)
                }
            }
        }
    }

    // MARK: Private

    private let calendar: Calendar
    private let monthsLayout: MonthsLayout
    private let visibleDateRange: ClosedRange<Date>

    private let monthDateFormatter: DateFormatter

    @StateObject private var calendarViewProxy = CalendarViewProxy()
}



#Preview {
    NavigationStack {
        JournalCalendarScreen()
    }
}

