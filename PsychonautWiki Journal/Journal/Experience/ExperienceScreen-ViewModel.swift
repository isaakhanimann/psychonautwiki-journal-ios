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

        private let fetchController: NSFetchedResultsController<Ingestion>
        @Published var timelineModel: TimelineModel?
        @Published var cumulativeDoses: [CumulativeDose] = []
        @Published var interactions: [Interaction] = []
        @Published var substancesUsed: [Substance] = []
        @Published var hiddenIngestions: [ObjectIdentifier] = []
        @Published var sortedIngestions: [Ingestion] = []


        override init() {
            let fetchRequest = Ingestion.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: true) ]
            fetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            fetchController.delegate = self
        }

        nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let ings = controller.fetchedObjects as? [Ingestion] else {return}
            Task { @MainActor in
                sortedIngestions = ings
                calculateScreen()
            }
        }

        func setupFetchRequestPredicateAndFetch(experience: Experience) {
            let predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Ingestion.experience.creationDate),
                experience.creationDateUnwrapped as NSDate
            )
            fetchController.fetchRequest.predicate = predicate
            try? fetchController.performFetch()
            let ings = fetchController.fetchedObjects ?? []
            sortedIngestions = ings
            calculateScreen()
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

        func startOrUpdateLiveActivity() {
            if #available(iOS 16.2, *) {
                Task { @MainActor in
                    ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: sortedIngestions))
                }
            }
        }

        func stopLiveActivity() {
            if #available(iOS 16.2, *) {
                ActivityManager.shared.stopActivity(everythingForEachLine: getEverythingForEachLine(from: sortedIngestions))
            }
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
            let model = TimelineModel(everythingForEachLine: everythingForEachLine)
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
