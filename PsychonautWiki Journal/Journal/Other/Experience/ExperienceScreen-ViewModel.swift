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

import Foundation
import CoreData

extension ExperienceScreen {

    @MainActor
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        private let ingestionFetchController: NSFetchedResultsController<Ingestion>
        private let ratingFetchController: NSFetchedResultsController<ShulginRating>
        @Published var timelineModel: TimelineModel?
        @Published var cumulativeDoses: [CumulativeDose] = []
        @Published var interactions: [Interaction] = []
        @Published var substancesUsed: [Substance] = []
        @Published var hiddenIngestions: [ObjectIdentifier] = []
        @Published var hiddenRatings: [ObjectIdentifier] = []
        @Published var sortedIngestions: [Ingestion] = []
        @Published var sortedRatings: [ShulginRating] = []

        var everythingForEachRating: [EverythingForOneRating] {
            sortedRatings
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
            super.init()
            ingestionFetchController.delegate = self
            ratingFetchController.delegate = self
        }

        nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let ings = controller.fetchedObjects as? [Ingestion] {
                Task { @MainActor in
                    sortedIngestions = ings
                    calculateScreen()
                }
            }
            if let ratings = controller.fetchedObjects as? [ShulginRating] {
                Task { @MainActor in
                    sortedRatings = ratings
                    calculateScreen()
                }
            }
        }

        func reloadScreen(experience: Experience) {
            reloadIngestions(experience: experience)
            reloadRatings(experience: experience)
            calculateScreen()
        }

        private func reloadIngestions(experience: Experience) {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Ingestion.experience.creationDate),
                experience.creationDateUnwrapped as NSDate
            )
            ingestionFetchController.fetchRequest.predicate = predicate
            try? ingestionFetchController.performFetch()
            sortedIngestions = ingestionFetchController.fetchedObjects ?? []
        }

        private func reloadRatings(experience: Experience) {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(ShulginRating.experience.creationDate),
                experience.creationDateUnwrapped as NSDate
            )
            ratingFetchController.fetchRequest.predicate = predicate
            try? ratingFetchController.performFetch()
            sortedRatings = ratingFetchController.fetchedObjects ?? []
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
                if let lastTime = sortedIngestions.last?.time, lastTime > Date.now.addingTimeInterval(-12*60*60) {
                    startOrUpdateLiveActivity()
                }
            }
        }

        @available(iOS 16.2, *)
        func startOrUpdateLiveActivity() {
            Task { @MainActor in
                ActivityManager.shared.startOrUpdateActivity(
                    everythingForEachLine: getEverythingForEachLine(from: sortedIngestions),
                    everythingForEachRating: everythingForEachRating
                )
            }
        }

        @available(iOS 16.2, *)
        func stopLiveActivity() {
            ActivityManager.shared.stopActivity(
                everythingForEachLine: getEverythingForEachLine(from: sortedIngestions),
                everythingForEachRating: everythingForEachRating
            )
        }

        private func setSubstances() {
            self.substancesUsed = sortedIngestions
                .map { $0.substanceNameUnwrapped }
                .uniqued()
                .compactMap { SubstanceRepo.shared.getSubstance(name: $0) }
        }

        private func calculateTimeline() {
            let ingestionsToShow = sortedIngestions.filter {!hiddenIngestions.contains($0.id)}
            let everythingForEachLine = getEverythingForEachLine(from: ingestionsToShow)
            let model = TimelineModel(
                everythingForEachLine: everythingForEachLine,
                everythingForEachRating: everythingForEachRating
            )
            timelineModel = model
        }

        private func calculateCumulativeDoses() {
            let ingestionsBySubstance = Dictionary(grouping: sortedIngestions, by: { $0.substanceNameUnwrapped })
            let cumu: [CumulativeDose] = ingestionsBySubstance.compactMap { (substanceName: String, ingestions: [Ingestion]) in
                guard ingestions.count > 1 else {return nil}
                guard let color = ingestions.first?.substanceColor else {return nil}
                return CumulativeDose(ingestionsForSubstance: ingestions, substanceName: substanceName, substanceColor: color)
            }
            cumulativeDoses = cumu
        }

        private func findInteractions() {
            let substanceNames = sortedIngestions.map { $0.substanceNameUnwrapped }.uniqued()
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
