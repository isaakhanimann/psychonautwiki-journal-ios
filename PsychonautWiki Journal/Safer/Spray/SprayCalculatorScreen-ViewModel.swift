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

extension SprayCalculatorScreen {
    @MainActor
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        private let sprayFetchController: NSFetchedResultsController<Spray>
        @Published var sprayModels: [SprayModel] = []
        @Published var selectedSpray: SprayModel? {
            didSet {
                maybeUpdateTotalWeight()
            }
        }

        @Published var units = WeightUnit.mg
        @Published var weightPerSprayText = "" {
            didSet {
                maybeUpdateTotalWeight()
            }
        }

        @Published var liquidAmountInMlText = "" {
            didSet {
                maybeUpdateTotalWeight()
            }
        }

        @Published var totalWeightText = "" {
            didSet {
                maybeUpdateLiquidVolume()
            }
        }

        @Published var purityInPercentText = ""
        @Published var isShowingAddSpray = false

        var weightPerSpray: Double? {
            getDouble(from: weightPerSprayText)
        }

        var liquidAmountInMl: Double? {
            getDouble(from: liquidAmountInMlText)
        }

        var purityInPercent: Double? {
            getDouble(from: purityInPercentText)
        }

        var totalWeight: Double? {
            getDouble(from: totalWeightText)
        }

        var doseAdjustedToPurity: Double? {
            guard let totalWeight, let purityInPercent else { return nil }
            return totalWeight * 100 / purityInPercent
        }

        private func maybeUpdateTotalWeight() {
            if let liquidAmountInMl, let selectedSpray, let weightPerSpray {
                let numSprays = liquidAmountInMl * selectedSpray.numSprays / selectedSpray.contentInMl
                let result = numSprays * weightPerSpray
                let resultText = result.asRoundedReadableString
                if resultText != totalWeightText {
                    totalWeightText = resultText
                }
            }
        }

        private func maybeUpdateLiquidVolume() {
            if let totalWeight, let selectedSpray, let weightPerSpray {
                let numSprays = totalWeight / weightPerSpray
                let result = numSprays * selectedSpray.contentInMl / selectedSpray.numSprays
                let resultText = result.asRoundedReadableString
                if resultText != liquidAmountInMlText {
                    liquidAmountInMlText = resultText
                }
            }
        }

        override init() {
            let sprayFetchRequest = Spray.fetchRequest()
            sprayFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Spray.creationDate, ascending: false)]
            sprayFetchController = NSFetchedResultsController(
                fetchRequest: sprayFetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            sprayFetchController.delegate = self
            do {
                try sprayFetchController.performFetch()
                let sprays = sprayFetchController.fetchedObjects ?? []
                assignToSprayModels(sprays: sprays)
            } catch {
                NSLog("Error: could not fetch CustomSubstances")
            }
        }

        public nonisolated func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let sprays = controller.fetchedObjects as? [Spray] else { return }
            Task { @MainActor in
                assignToSprayModels(sprays: sprays)
            }
        }

        private func assignToSprayModels(sprays: [Spray]) {
            sprayModels = sprays.map { spray in
                SprayModel(name: spray.nameUnwrapped, numSprays: spray.numSprays, contentInMl: spray.contentInMl, spray: spray)
            }
            if let sel = sprays.first(where: { spray in
                spray.isPreferred
            }) {
                selectedSpray = SprayModel(name: sel.nameUnwrapped, numSprays: sel.numSprays, contentInMl: sel.contentInMl, spray: sel)
            } else {
                selectedSpray = sprayModels.first
            }
        }

        func saveSelect() {
            let sprays = sprayModels.compactMap { $0.spray }
            sprays.forEach { spray in
                spray.isPreferred = false
            }
            if let selectedSpray = selectedSpray?.spray {
                selectedSpray.isPreferred = true
            }
            let context = PersistenceController.shared.viewContext
            if context.hasChanges {
                try? context.save()
            }
        }

        func deleteSprays(at offsets: IndexSet) {
            let context = PersistenceController.shared.viewContext
            let spraysToDelete = offsets.compactMap { sprayModels[$0].spray }
            for spray in spraysToDelete {
                context.delete(spray)
            }
            do {
                try context.save()
            } catch {
                assertionFailure("Failed to delete sprays")
            }
        }
    }
}
