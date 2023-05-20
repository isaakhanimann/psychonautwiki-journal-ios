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
        @Published var selectedSpray: SprayModel? = nil
        @Published var units = WeightUnit.mg
        @Published var perSprayText = ""
        @Published var perSpray: Double? = nil
        @Published var liquidAmountInMlText = ""
        @Published var liquidAmountInMl: Double? = nil
        @Published var purityInPercentText = ""
        @Published var purityInPercent: Double? = nil
        @Published var isShowingAddSpray = false
        @Published var isShowingEditSpray = false


        //    var mlPerSpray: Double? {
        //        guard let numSprays else {return nil}
        //        guard let liquidAmountInML else {return nil}
        //        return liquidAmountInML/numSprays
        //    }
        //
        //    var amountResult: Double? {
        //        guard let perSpray else {return nil}
        //        guard let numSprays else {return nil}
        //        return perSpray * numSprays
        //    }

        override init() {
            let sprayFetchRequest = Spray.fetchRequest()
            sprayFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Spray.creationDate, ascending: false) ]
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

        nonisolated public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let sprays = controller.fetchedObjects as? [Spray] else {return}
            Task { @MainActor in
                assignToSprayModels(sprays: sprays)
            }
        }

        private func assignToSprayModels(sprays: [Spray]) {
            sprayModels = sprays.map({ spray in
                SprayModel(id: spray.id,name: spray.nameUnwrapped, numSprays: spray.numSprays, contentInMl: spray.contentInMl)
            })
            selectedSpray = sprayModels.first
        }

        func selectSpray(sprayModel: SprayModel) {

        }

        func deleteSpray(sprayModel: SprayModel) {

        }
    }
}
