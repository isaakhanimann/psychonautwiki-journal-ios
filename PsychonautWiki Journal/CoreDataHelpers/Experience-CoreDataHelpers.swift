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

import SwiftUI

extension Experience: Comparable {
    public static func < (lhs: Experience, rhs: Experience) -> Bool {
        lhs.sortDateUnwrapped > rhs.sortDateUnwrapped
    }

    var sortDateUnwrapped: Date {
        ingestionsSorted.first?.time ?? sortDate ?? creationDateUnwrapped
    }

    var creationDateUnwrapped: Date {
        creationDate ?? Date()
    }

    var titleUnwrapped: String {
        title ?? creationDateUnwrappedString
    }

    var textUnwrapped: String {
        text ?? ""
    }

    var creationDateUnwrappedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter.string(from: creationDateUnwrapped)
    }

    var myIngestionsSorted: [Ingestion] {
        ingestionsSorted.filter { ing in
            if let consumerName = ing.consumerName {
                return consumerName.trimmingCharacters(in: .whitespaces).isEmpty
            } else {
                return true
            }
        }
    }

    var ingestionsSorted: [Ingestion] {
        (ingestions?.allObjects as? [Ingestion] ?? []).sorted()
    }

    var timedNotesSorted: [TimedNote] {
        (timedNotes?.allObjects as? [TimedNote] ?? []).sorted()
    }

    var consumerNames: [String] {
        ingestionsSorted.compactMap { ing in
            if let consumerName = ing.consumerName, !consumerName.trimmingCharacters(in: .whitespaces).isEmpty {
                return consumerName
            } else {
                return nil
            }
        }.uniqued()
    }

    var ratingsUnwrapped: [ShulginRating] {
        ratings?.allObjects as? [ShulginRating] ?? []
    }

    var ratingsWithTimeSorted: [ShulginRating] {
        ratingsUnwrapped.filter { rating in
            rating.time != nil
        }.sorted()
    }

    var maxRating: ShulginRatingOption? {
        ratingsUnwrapped.map { rating in
            rating.optionUnwrapped
        }.max()
    }

    var overallRating: ShulginRating? {
        ratingsUnwrapped.first { rating in
            rating.time == nil
        }
    }

    var ingestionColors: [Color] {
        var colors = [Color]()
        for ingestion in ingestionsSorted {
            colors.append(ingestion.substanceColor.swiftUIColor)
        }
        return colors
    }

    var distinctUsedSubstanceNames: [String] {
        ingestionsSorted.map { ing in
            ing.substanceNameUnwrapped
        }.uniqued()
    }

    var isCurrent: Bool {
        let twelveHours: TimeInterval = 12 * 60 * 60
        if let lastIngestionTime = ingestionsSorted.last?.time,
           Date().timeIntervalSinceReferenceDate - lastIngestionTime.timeIntervalSinceReferenceDate < twelveHours {
            return true
        } else if Date().timeIntervalSinceReferenceDate - sortDateUnwrapped.timeIntervalSinceReferenceDate < twelveHours {
            return true
        } else {
            return false
        }
    }

    var timedNotesForTimeline: [EverythingForOneTimedNote] {
        timedNotesSorted.filter { $0.isPartOfTimeline }.map { timedNote in
            EverythingForOneTimedNote(
                time: timedNote.timeUnwrapped,
                color: timedNote.color
            )
        }
    }

    var otherIngestions: [Ingestion] {
        ingestionsSorted.filter { ing in
            !myIngestionsSorted.contains(ing)
        }.sorted()
    }

    var myCumulativeDoses: [CumulativeDose] {
        let ingestionsBySubstance = Dictionary(grouping: myIngestionsSorted, by: { $0.substanceNameUnwrapped })
        return ingestionsBySubstance.compactMap { (substanceName: String, ingestions: [Ingestion]) in
            guard ingestions.count > 1 else { return nil }
            guard let color = ingestions.first?.substanceColor else { return nil }
            return CumulativeDose(ingestionsForSubstance: ingestions, substanceName: substanceName, substanceColor: color)
        }
    }

    var interactions: [Interaction] {
        let substanceNames = ingestionsSorted.filter({ $0.consumerName == nil}).map { $0.substanceNameUnwrapped }.uniqued()
        var interactions: [Interaction] = []
        for subIndex in 0 ..< substanceNames.count {
            let name = substanceNames[subIndex]
            let otherNames = substanceNames.dropFirst(subIndex + 1)
            for otherName in otherNames {
                if let newInteraction = InteractionChecker.getInteractionBetween(aName: name, bName: otherName) {
                    interactions.append(newInteraction)
                }
            }
        }
        return interactions.sorted(by: { interaction1, interaction2 in
            interaction1.interactionType.dangerCount > interaction2.interactionType.dangerCount
        })
    }

    var substancesUsed: [Substance] {
        ingestionsSorted
            .map { $0.substanceNameUnwrapped }
            .uniqued()
            .compactMap { SubstanceRepo.shared.getSubstance(name: $0) }
    }

    func getMyTimeLineModel(
        hiddenIngestions: [ObjectIdentifier],
        hiddenRatings: [ObjectIdentifier],
        areRedosesDrawnIndividually: Bool,
        areSubstanceHeightsIndependent: Bool
    ) -> TimelineModel {
        getTimelineModel(
            from: myIngestionsSorted.filter { !hiddenIngestions.contains($0.id) },
            everythingForEachRating: ratingsWithTimeSorted
                .filter { !hiddenRatings.contains($0.id) }
                .map { shulgin in
                    EverythingForOneRating(time: shulgin.timeUnwrapped, option: shulgin.optionUnwrapped)
                },
            everythingForEachTimedNote: timedNotesForTimeline,
            areRedosesDrawnIndividually: areRedosesDrawnIndividually,
            areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
        )
    }

    func getConsumers(hiddenIngestions: [ObjectIdentifier], areRedosesDrawnIndividually: Bool, areSubstanceHeightsIndependent: Bool) -> [ConsumerWithIngestions] {
        let ingestionsByConsumer = Dictionary(grouping: otherIngestions, by: { $0.consumerName })
        var consumers = [ConsumerWithIngestions]()
        for (consumerName, ingestions) in ingestionsByConsumer {
            if let consumerName, !consumerName.trimmingCharacters(in: .whitespaces).isEmpty {
                let newConsumer = ConsumerWithIngestions(
                    consumerName: consumerName,
                    ingestionsSorted: ingestions.sorted(),
                    timelineModel: getTimelineModel(
                        from: ingestions.filter { !hiddenIngestions.contains($0.id) },
                        everythingForEachRating: [],
                        everythingForEachTimedNote: [],
                        areRedosesDrawnIndividually: areRedosesDrawnIndividually,
                        areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
                    )
                )
                consumers.append(newConsumer)
            }
        }
        return consumers.sorted()
    }

    private func getTimelineModel(
        from ingestions: [Ingestion],
        everythingForEachRating: [EverythingForOneRating],
        everythingForEachTimedNote: [EverythingForOneTimedNote],
        areRedosesDrawnIndividually: Bool,
        areSubstanceHeightsIndependent: Bool
    ) -> TimelineModel {
        TimelineModel(
            substanceGroups: getSubstanceIngestionGroups(ingestions: ingestions),
            everythingForEachRating: everythingForEachRating,
            everythingForEachTimedNote: everythingForEachTimedNote,
            areRedosesDrawnIndividually: areRedosesDrawnIndividually,
            areSubstanceHeightsIndependent: areSubstanceHeightsIndependent
        )
    }

    struct ChartData {
        let toleranceWindows: [ToleranceWindow]
        let substancesInChart: [SubstanceWithToleranceAndColor]
        let numberOfSubstancesInToleranceChart: Int
        let namesOfSubstancesWithMissingTolerance: [String]
    }

    var chartData: ChartData {
        let lastIngestionDate = ingestionsSorted.last?.timeUnwrapped ?? Date.now
        let threeMonthsBefore = lastIngestionDate.addingTimeInterval(-3 * 30 * 24 * 60 * 60)
        let ingestionsForChart = PersistenceController.shared.getIngestionsBetween(startDate: threeMonthsBefore, endDate: lastIngestionDate).filter { ing in
            if let consumerName = ing.consumerName, !consumerName.trimmingCharacters(in: .whitespaces).isEmpty {
                return false
            } else {
                return true
            }
        }
        let substanceDays = ingestionsForChart.map { ing in
            SubstanceAndDay(substanceName: ing.substanceNameUnwrapped, day: ing.timeUnwrapped)
        }
        let substanceCompanions = PersistenceController.shared.getSubstanceCompanions()
        let allWindowsInLast3Months = ToleranceChartCalculator.getToleranceWindows(
            from: substanceDays,
            substanceCompanions: Array(substanceCompanions)
        )
        let toleranceWindowsSorted = allWindowsInLast3Months.sorted { lhs, rhs in
            lhs.start < rhs.start // sort tolerance windows so that they are always drawn in the same order and don't switch row on redraw
        }
        let namesOfSubstancesInChart = toleranceWindowsSorted.map { $0.substanceName }.uniqued()
        let substancesInChart = SubstanceRepo.shared.getSubstances(names: namesOfSubstancesInChart).map { sub in
            sub.toSubstanceWithToleranceAndColor(substanceColor: substanceCompanions.first(where: { $0.substanceNameUnwrapped == sub.name })?.color ?? .red)
        }
        let numberOfSubstancesInToleranceChart = namesOfSubstancesInChart.count
        let namesOfSubstancesInIngestions = Set(ingestionsForChart.map { $0.substanceNameUnwrapped })
        let namesOfSubstancesWithWindows = Set(allWindowsInLast3Months.map { $0.substanceName })
        let namesOfSubstancesWithoutWindows = namesOfSubstancesInIngestions.subtracting(namesOfSubstancesWithWindows)
        let namesOfSubstancesWithMissingTolerance = Array(namesOfSubstancesWithoutWindows)
        return ChartData(
            toleranceWindows: toleranceWindowsSorted,
            substancesInChart: substancesInChart,
            numberOfSubstancesInToleranceChart: numberOfSubstancesInToleranceChart,
            namesOfSubstancesWithMissingTolerance: namesOfSubstancesWithMissingTolerance
        )
    }
}
