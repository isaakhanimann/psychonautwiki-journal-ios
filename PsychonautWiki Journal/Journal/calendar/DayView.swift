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

struct DayView: View {

    private let dayComponents: DayComponents
    @FetchRequest var ingestions : FetchedResults<Ingestion>
    let isToday: Bool

    init(dayComponents: DayComponents) {
        self.dayComponents = dayComponents
        let startOfDay = Calendar.current.date(from: dayComponents.components) ?? .now
        let laterThanStart = NSPredicate(format: "time > %@", startOfDay as NSDate)
        var components = DateComponents()
            components.day = 1
            components.second = -1
        let endOfDay = Calendar.current.date(byAdding: components, to: startOfDay) ?? .now
        let earlierThanEnd = NSPredicate(format: "time < %@", endOfDay as NSDate)
        let compoundPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [laterThanStart, earlierThanEnd])
        self._ingestions = FetchRequest(entity: Ingestion.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)], predicate: compoundPredicate)
        let startOfToday = Calendar.current.startOfDay(for: .now)
        isToday = startOfDay == startOfToday
    }

    private let colorHeight: Double = 6

    var body: some View {
        if let firstExperience = experiences.first {
            if experiences.count > 1 {
                NavigationLink(value: GlobalNavigationDestination.chooseExperience(experiences: experiences)) {
                    experienceDayLabel
                }
            } else {
                NavigationLink(value: GlobalNavigationDestination.experience(experience: firstExperience)) {
                    experienceDayLabel
                }
            }
        } else {
            VStack(spacing: 0) {
                textWithColor
                Color.clear.frame(height: colorHeight)
            }
        }
    }

    private var textWithColor: Text {
        if isToday {
            text.foregroundColor(.accentColor)
        } else if ingestions.isEmpty {
            text.foregroundColor(.secondary)
        } else {
            text.foregroundColor(.primary)
        }
    }

    private var text: Text {
        Text("\(dayComponents.day)")
    }

    private var experienceDayLabel: some View {
        VStack(spacing: 0) {
            textWithColor
            CalendarColorRectangle(colors: ingestions.map({$0.substanceColor.swiftUIColor}))
                .frame(height: colorHeight).padding(.horizontal, 5)
        }
    }

    private var experiences: [Experience] {
        ingestions.compactMap {$0.experience}.uniqued().sorted { lhs, rhs in
            lhs.sortDateUnwrapped < rhs.sortDateUnwrapped
        }
    }
}
