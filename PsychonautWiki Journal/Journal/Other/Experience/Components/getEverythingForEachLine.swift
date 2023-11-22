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

import Foundation

func getMinInfoForEachLine(from ingestions: [Ingestion]) -> [IngestionMinInfoForLine] {
    ingestions.map { ingestion in
        IngestionMinInfoForLine(
            substanceName: ingestion.substanceNameUnwrapped,
            color: ingestion.substanceColor,
            route: ingestion.administrationRouteUnwrapped,
            dose: ingestion.doseUnwrapped,
            ingestionTime: ingestion.timeUnwrapped)
    }
}

struct SubstanceIngestionGroup {
    let substanceName: String
    let color: SubstanceColor
    let routeMinInfos: [RouteMinInfo]
}

struct RouteMinInfo {
    let route: AdministrationRoute
    let doseMinInfos: [DoseMinInfo]
}

struct DoseMinInfo {
    let dose: Double?
    let ingestionTime: Date
}

// this is ready to be sent to live activity
func getSubstanceIngestionGroups(ingestions: [Ingestion]) -> [SubstanceIngestionGroup] {
    let minInfoForEachLine = getMinInfoForEachLine(from: ingestions)
    let substanceDict = Dictionary(grouping: minInfoForEachLine) { minInfo in
        minInfo.substanceName
    }
    let substanceIngestionGroups: [SubstanceIngestionGroup] = substanceDict.compactMap { (substanceName: String, ingestionMinInfoForLines: [IngestionMinInfoForLine]) in
        guard let color = ingestionMinInfoForLines.first?.color else {return nil}
        let routeDict = Dictionary(grouping: ingestionMinInfoForLines) { value in
            value.route
        }
        let routeMinInfos = routeDict.map { (route: AdministrationRoute, values: [IngestionMinInfoForLine]) in
            let doseMinInfos = values.map { ingestionMinInfo in
                DoseMinInfo(
                    dose: ingestionMinInfo.dose,
                    ingestionTime: ingestionMinInfo.ingestionTime
                )
            }
            return RouteMinInfo(
                route: route,
                doseMinInfos: doseMinInfos)

        }
        return SubstanceIngestionGroup(
            substanceName: substanceName,
            color: color,
            routeMinInfos: routeMinInfos)
    }
    return substanceIngestionGroups
}



struct EnhancedSubstanceGroup {
    let color: SubstanceColor
    let enhancedRoaGroups: [EnhancedRoaGroup]
}

struct EnhancedRoaGroup {
    let roaDuration: RoaDuration?
    let roaStrength: Double
    let doseMinInfos: [EnhancedDose]
}

struct EnhancedDose {
    let verticalWeight: Double
    let horizontalWeight: Double
}

func getFinalSubstanceGroup(substanceIngestionGroups: [SubstanceIngestionGroup]) -> [FinalSubstanceGroup] {
    substanceIngestionGroups.map { substanceIngestionGroup in
        let substance = SubstanceRepo.shared.getSubstance(name: substanceIngestionGroup.substanceName)
        let finalRoaGroups = substanceIngestionGroup.routeMinInfos.map { routeMinInfo in
            let roaDuration = substance?.getDuration(for: routeMinInfo.route)
            let allRoas = substanceIngestionGroup.routeMinInfos.map({$0.route})
            let roaStrength = 1
            let finalRelativeDoses = routeMinInfo.doseMinInfos.map { doseMinInfo in
                let heightRelative = roaStrength * doseMinInfo.dose
                let horizontalWeight = 0.5
                return FinalRelativeDose(
                    heightRelative: heightRelative,
                    horizontalWeight: horizontalWeight)
            }
            return FinalRoaGroup(
                roaDuration: roaDuration,
                finalRelativeDoses: finalRelativeDoses)
        }
        return FinalSubstanceGroup(
            color: substanceIngestionGroup.color,
            finalRoaGroups: finalRoaGroups)
    }
}


struct FinalSubstanceGroup {
    let color: SubstanceColor
    let finalRoaGroups: [FinalRoaGroup]
}

struct FinalRoaGroup {
    let roaDuration: RoaDuration?
    let finalRelativeDoses: [FinalRelativeDose]
}

struct FinalRelativeDose {
    let heightRelative: Double
    let horizontalWeight: Double
}




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
            substanceName: ingestion.substanceNameUnwrapped,
            route: ingestion.administrationRouteUnwrapped,
            roaDuration: roaDuration,
            onsetDelayInHours: ingestion.stomachFullnessUnwrapped?.onsetDelayForOralInHours ?? 0,
            startTime: ingestion.timeUnwrapped,
            horizontalWeight: horizontalWeight,
            verticalWeight: verticalWeight,
            color: ingestion.substanceColor
        )
    }
}
