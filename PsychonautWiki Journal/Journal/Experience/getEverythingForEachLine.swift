//
//  getEverythingForEachLine.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 02.01.23.
//

import Foundation

func getEverythingForEachLine(from ingestions: [Ingestion]) -> [EverythingForOneLine] {
    let dosePairs: [(String, Double)] = ingestions.compactMap({ ing in
        guard let dose = ing.doseUnwrapped else {return nil}
        return (ing.substanceNameUnwrapped, dose)
    })
    let maxDoses = Dictionary(dosePairs) { dose1, dose2 in
        max(dose1, dose2)
    }
    return ingestions.map { ingestion in
        let substanceName = ingestion.substanceNameUnwrapped
        let substance = SubstanceRepo.shared.getSubstance(name: substanceName)
        let roaDuration = substance?.getDuration(for: ingestion.administrationRouteUnwrapped)
        let roaDose = substance?.getDose(for: ingestion.administrationRouteUnwrapped)
        var horizontalWeight = 0.5
        if let dose = ingestion.doseUnwrapped, let units = ingestion.units, let roaDose {
            let doseType = roaDose.getRangeType(for: dose, with: units)
            switch doseType {
            case .thresh:
                horizontalWeight = 0
            case .light:
                horizontalWeight = 0.25
            case .common:
                horizontalWeight = 0.5
            case .strong:
                horizontalWeight = 0.75
            case .heavy:
                horizontalWeight = 1
            case .none:
                horizontalWeight = 0.5
            }
        }
        var verticalWeight = 1.0
        if let dose = ingestion.doseUnwrapped, let max = maxDoses[substanceName] {
            verticalWeight = dose/max
        }
        return EverythingForOneLine(
            roaDuration: roaDuration,
            startTime: ingestion.timeUnwrapped,
            horizontalWeight: horizontalWeight,
            verticalWeight: verticalWeight,
            color: ingestion.substanceColor
        )
    }
}
