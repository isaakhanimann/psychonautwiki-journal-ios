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

import CoreData
import UIKit

func playHapticFeedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
}

// swiftlint:disable force_cast
func getCurrentAppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
}
// swiftlint:enable force_cast

func getColor(for substanceName: String) -> SubstanceColor {
    let fetchRequest = SubstanceCompanion.fetchRequest()
    fetchRequest.fetchLimit = 1
    fetchRequest.predicate = NSPredicate(
        format: "substanceName = %@", substanceName
    )
    let maybeColor = try? PersistenceController.shared.viewContext.fetch(fetchRequest).first?.color
    return maybeColor ?? SubstanceColor.purple
}

func getDateFromMillis(millis: UInt64) -> Date {
    let secondsSince1970: TimeInterval = Double(millis) / 1000
    return Date(timeIntervalSince1970: secondsSince1970)
}

func getDate(year: Int, month: Int, day: Int) -> Date? {
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    return calendar.date(from: dateComponents)
}

func getDouble(from text: String) -> Double? {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .decimal
    return formatter.number(from: text)?.doubleValue
}
