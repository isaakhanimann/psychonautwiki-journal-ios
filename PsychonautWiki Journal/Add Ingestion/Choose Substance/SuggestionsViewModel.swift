//
//  SuggestionsViewModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 13.12.22.
//

import Foundation

class SuggestionsViewModel: ObservableObject {

    let suggestions: [Suggestion]

    init() {
        let ingestionFetchRequest = Ingestion.fetchRequest()
        ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
        ingestionFetchRequest.fetchLimit = 100
        let ingestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
        let groupedBySubstance = Dictionary(grouping: ingestions, by: { $0.substanceNameUnwrapped })
        suggestions = []

//        groupedBySubstance.map { (substanceName: String, ingestionsWithSameSubstance: [Ingestion]) in
//            let groupedByRoute = Dictionary(grouping: ingestionsWithSameSubstance, by: { $0.administrationRouteUnwrapped })
//            let substance = SubstanceRepo.shared.getSubstance(name: substanceName)
//            let substanceColor = ingestionsWithSameSubstance.first?.substanceColor ?? .red
//            let routesAndDoses = groupedByRoute.map { (route: AdministrationRoute, ingestions: [Ingestion]) in
//                RouteAndDoses(
//                    route: route,
//                    units: ingestions.first?.unitsUnwrapped ?? "",
//                    doses: ingestions.map { ing in
//                        DoseAndUnit(dose: ing.doseUnwrapped, units: ing.unitsUnwrapped)
//                    }.uniqued()
//                )
//            }.sorted { r1, r2 in
//                r1.doses.count > r2.doses.count
//            }
//            return Suggestion(
//                substanceName: substanceName,
//                substance: substance,
//                substanceColor: substanceColor,
//                routesAndDoses: routesAndDoses
//            )
//
//        }
    }
}



