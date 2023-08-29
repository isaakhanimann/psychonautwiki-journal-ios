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

import CoreData

extension ExperienceScreen {

    @MainActor
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        var experience: Experience? = nil
        private let ingestionFetchController: NSFetchedResultsController<Ingestion>
        private let ratingFetchController: NSFetchedResultsController<ShulginRating>
        private let timedNotesFetchController: NSFetchedResultsController<TimedNote>
        @Published var timelineModel: TimelineModel?
        @Published var cumulativeDoses: [CumulativeDose] = []
        @Published var interactions: [Interaction] = []
        @Published var substancesUsed: [Substance] = []
        @Published var hiddenIngestions: [ObjectIdentifier] = []
        @Published var hiddenRatings: [ObjectIdentifier] = []
        @Published var ingestionsSorted: [Ingestion] = []
        @Published var ratingsWithTimeSorted: [ShulginRating] = []
        @Published var timedNotesForTimeline: [EverythingForOneTimedNote] = []
        @Published var toleranceWindows: [ToleranceWindow] = []
        @Published var numberOfSubstancesInToleranceChart = 0
        @Published var substancesInChart: [SubstanceWithToleranceAndColor] = []
        @Published var namesOfSubstancesWithMissingTolerance: [String] = []
        @Published var consumers: [ConsumerWithIngestions] = []

        var everythingForEachRating: [EverythingForOneRating] {
            ratingsWithTimeSorted
                .filter {!hiddenRatings.contains($0.id)}
                .map({ shulgin in
                    EverythingForOneRating(time: shulgin.timeUnwrapped, option: shulgin.optionUnwrapped)
                })
        }

        override init() {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: true) ]
            ingestionFetchController = NSFetchedResultsController(
                fetchRequest: ingestionFetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            let ratingFetchRequest = ShulginRating.fetchRequest()
            ratingFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \ShulginRating.time, ascending: true) ]
            ratingFetchController = NSFetchedResultsController(
                fetchRequest: ratingFetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            let timedNotesFetchRequest = TimedNote.fetchRequest()
            timedNotesFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \TimedNote.time, ascending: true) ]
            timedNotesFetchController = NSFetchedResultsController(
                fetchRequest: timedNotesFetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            ingestionFetchController.delegate = self
            ratingFetchController.delegate = self
            timedNotesFetchController.delegate = self
        }

        nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            Task { @MainActor in
                if let experience {
                    reloadScreen(experience: experience)
                }
            }
        }

        func reloadScreen(experience: Experience) {
            reloadIngestions(experience: experience)
            reloadRatings(experience: experience)
            reloadTimedNotes(experience: experience)
            calculateScreen()
            calculateChartData()
        }

        private func calculateChartData() {
            let lastIngestionDate = ingestionsSorted.last?.timeUnwrapped ?? Date.now
            let threeMonthsBefore = lastIngestionDate.addingTimeInterval(-3*30*24*60*60)
            let ingestionsForChart = PersistenceController.shared.getIngestionsBetween(startDate: threeMonthsBefore, endDate: lastIngestionDate)
            let substanceDays = ingestionsForChart.map { ing in
                SubstanceAndDay(substanceName: ing.substanceNameUnwrapped, day: ing.timeUnwrapped)
            }
            let substanceCompanions = PersistenceController.shared.getSubstanceCompanions()
            let allWindowsInLast3Months = ToleranceChartCalculator.getToleranceWindows(
                from: substanceDays,
                substanceCompanions: Array(substanceCompanions)
            )
            self.toleranceWindows = getWindowsOfSubstancesThatHaveAWindowAtTimeOfExperience(windows: allWindowsInLast3Months)
            let namesOfSubstancesInChart = toleranceWindows.map({$0.substanceName}).uniqued()
            substancesInChart = SubstanceRepo.shared.getSubstances(names: namesOfSubstancesInChart).map({ sub in
                sub.toSubstanceWithToleranceAndColor(substanceColor: substanceCompanions.first(where: { $0.substanceNameUnwrapped == sub.name})?.color ?? .red)
            })
            numberOfSubstancesInToleranceChart = namesOfSubstancesInChart.count
            let namesOfSubstancesInIngestions = Set(ingestionsForChart.map({$0.substanceNameUnwrapped}))
            let namesOfSubstancesWithWindows = Set(allWindowsInLast3Months.map({$0.substanceName}))
            let namesOfSubstancesWithoutWindows = namesOfSubstancesInIngestions.subtracting(namesOfSubstancesWithWindows)
            namesOfSubstancesWithMissingTolerance = Array(namesOfSubstancesWithoutWindows)
        }

        private func getWindowsOfSubstancesThatHaveAWindowAtTimeOfExperience(windows: [ToleranceWindow]) -> [ToleranceWindow] {
            let time = experience?.sortDateUnwrapped ?? ingestionsSorted.first?.time ?? Date.now
            let dateWithoutTime = time.getDateWithoutTime()
            let filteredWindows = windows.filter { win in
                win.contains(date: dateWithoutTime)
            }
            let substancesInFilteredWindows = Set(filteredWindows.map({$0.substanceName}))
            return windows.filter { win in
                substancesInFilteredWindows.contains(win.substanceName)
            }
        }

        private func reloadIngestions(experience: Experience) {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Ingestion.experience.creationDate),
                experience.creationDateUnwrapped as NSDate
            )
            ingestionFetchController.fetchRequest.predicate = predicate
            try? ingestionFetchController.performFetch()
            let allIngestions = ingestionFetchController.fetchedObjects ?? []
            splitIngestions(allIngestions: allIngestions)
        }

        private func splitIngestions(allIngestions: [Ingestion]) {
            let ingestionsByConsumer = Dictionary(grouping: allIngestions, by: {$0.consumerName})
            var consumers = [ConsumerWithIngestions]()
            for (consumerName, ingestions) in ingestionsByConsumer {
                if let consumerName, !consumerName.trimmingCharacters(in: .whitespaces).isEmpty {
                    let newConsumer = ConsumerWithIngestions(consumerName: consumerName, ingestionsSorted: ingestions.sorted())
                    consumers.append(newConsumer)
                } else {
                    ingestionsSorted = ingestions.sorted()
                }
            }
            self.consumers = consumers.sorted()
        }

        private func reloadRatings(experience: Experience) {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ShulginRating.experience.creationDate),
                experience.creationDateUnwrapped as NSDate
            )
            ratingFetchController.fetchRequest.predicate = predicate
            try? ratingFetchController.performFetch()
            ratingsWithTimeSorted = (ratingFetchController.fetchedObjects ?? []).filter({ rating in
                rating.time != nil
            })
        }

        private func reloadTimedNotes(experience: Experience) {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(TimedNote.experience.creationDate),
                experience.creationDateUnwrapped as NSDate
            )
            timedNotesFetchController.fetchRequest.predicate = predicate
            try? timedNotesFetchController.performFetch()
            timedNotesForTimeline = (timedNotesFetchController.fetchedObjects ?? []).filter({$0.isPartOfTimeline}).map({ timedNote in
                EverythingForOneTimedNote(
                    time: timedNote.timeUnwrapped,
                    color: timedNote.color)
            })
        }

        func showIngestion(id: ObjectIdentifier) {
            hiddenIngestions.removeAll { hiddenID in
                hiddenID == id
            }
            calculateTimeline()
        }

        func hideIngestion(id: ObjectIdentifier) {
            hiddenIngestions.append(id)
            calculateTimeline()
        }

        func showRating(id: ObjectIdentifier) {
            hiddenRatings.removeAll { hiddenID in
                hiddenID == id
            }
            calculateTimeline()
        }

        func hideRating(id: ObjectIdentifier) {
            hiddenRatings.append(id)
            calculateTimeline()
        }

        private func calculateScreen() {
            setSubstances()
            calculateCumulativeDoses()
            calculateTimeline()
            findInteractions()
            if #available(iOS 16.2, *) {
                if let lastTime = ingestionsSorted.last?.time, lastTime > Date.now.addingTimeInterval(-12*60*60) && ActivityManager.shared.isActivityActive {
                    startOrUpdateLiveActivity()
                }
            }
        }

        @available(iOS 16.2, *)
        func startOrUpdateLiveActivity() {
            Task {
                await ActivityManager.shared.startOrUpdateActivity(
                    everythingForEachLine: getEverythingForEachLine(from: ingestionsSorted),
                    everythingForEachRating: everythingForEachRating,
                    everythingForEachTimedNote: timedNotesForTimeline
                )
            }
        }

        @available(iOS 16.2, *)
        func stopLiveActivity() {
            Task {
                await ActivityManager.shared.stopActivity(
                    everythingForEachLine: getEverythingForEachLine(from: ingestionsSorted),
                    everythingForEachRating: everythingForEachRating,
                    everythingForEachTimedNote: timedNotesForTimeline
                )
            }
        }

        private func setSubstances() {
            self.substancesUsed = ingestionsSorted
                .map { $0.substanceNameUnwrapped }
                .uniqued()
                .compactMap { SubstanceRepo.shared.getSubstance(name: $0) }
        }

        private func calculateTimeline() {
            let ingestionsToShow = ingestionsSorted.filter {!hiddenIngestions.contains($0.id)}
            let everythingForEachLine = getEverythingForEachLine(from: ingestionsToShow)
            let model = TimelineModel(
                everythingForEachLine: everythingForEachLine,
                everythingForEachRating: everythingForEachRating,
                everythingForEachTimedNote: timedNotesForTimeline
            )
            timelineModel = model
        }

        private func calculateCumulativeDoses() {
            let ingestionsBySubstance = Dictionary(grouping: ingestionsSorted, by: { $0.substanceNameUnwrapped })
            let cumu: [CumulativeDose] = ingestionsBySubstance.compactMap { (substanceName: String, ingestions: [Ingestion]) in
                guard ingestions.count > 1 else {return nil}
                guard let color = ingestions.first?.substanceColor else {return nil}
                return CumulativeDose(ingestionsForSubstance: ingestions, substanceName: substanceName, substanceColor: color)
            }
            cumulativeDoses = cumu
        }

        private func findInteractions() {
            let substanceNames = ingestionsSorted.map { $0.substanceNameUnwrapped }.uniqued()
            var interactions: [Interaction] = []
            for subIndex in 0..<substanceNames.count {
                let name = substanceNames[subIndex]
                let otherNames = substanceNames.dropFirst(subIndex+1)
                for otherName in otherNames {
                    if let newInteraction = InteractionChecker.getInteractionBetween(aName: name, bName: otherName) {
                        interactions.append(newInteraction)
                    }
                }
            }
            self.interactions = interactions.sorted(by: { interaction1, interaction2 in
                interaction1.interactionType.dangerCount > interaction2.interactionType.dangerCount
            })
        }
    }
}
