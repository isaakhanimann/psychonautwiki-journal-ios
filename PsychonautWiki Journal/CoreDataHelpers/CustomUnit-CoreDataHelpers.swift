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

extension CustomUnit {
    var nameUnwrapped: String {
        name ?? ""
    }

    var creationDateUnwrapped: Date {
        creationDate ?? .now
    }

    var administrationRouteUnwrapped: AdministrationRoute {
        AdministrationRoute(rawValue: administrationRoute ?? "oral") ?? .oral
    }

    var doseUnwrapped: Double? {
        if dose == 0 {
            return nil
        } else {
            return dose
        }
    }

    var originalUnitUnwrapped: String {
        originalUnit ?? ""
    }

    var substanceNameUnwrapped: String {
        substanceName ?? ""
    }

    var substance: Substance? {
        SubstanceRepo.shared.getSubstance(name: substanceNameUnwrapped)
    }

    var roaDose: RoaDose? {
        substance?.getDose(for: administrationRouteUnwrapped)
    }

    var noteUnwrapped: String {
        note ?? ""
    }

    var estimatedDoseVarianceUnwrapped: Double? {
        if estimatedDoseVariance == 0 || !isEstimate {
            return nil
        } else {
            return estimatedDoseVariance
        }
    }

    var unitUnwrapped: String {
        unit ?? ""
    }

    var minInfo: CustomUnitMinInfo {
        CustomUnitMinInfo(dosePerUnit: doseUnwrapped, unit: unitUnwrapped)
    }

    var ingestionsUnwrapped: [Ingestion] {
        ingestions?.allObjects as? [Ingestion] ?? []
    }

    var doseOfOneUnitDescription: String {
        if let doseUnwrapped {
            if isEstimate {
                if let estimatedDoseVarianceUnwrapped {
                    return "\(doseUnwrapped.formatted())±\(estimatedDoseVarianceUnwrapped.formatted()) \(originalUnitUnwrapped)"
                } else {
                    return "~\(doseUnwrapped.formatted()) \(originalUnitUnwrapped)"
                }
            } else {
                return "\(doseUnwrapped.formatted()) \(originalUnitUnwrapped)"
            }
        } else {
            return "Unknown dose"
        }
    }

    var color: SubstanceColor? {
        let fetchRequest = SubstanceCompanion.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "substanceName == %@", substanceNameUnwrapped)
        let companions = try? PersistenceController.shared.viewContext.fetch(fetchRequest)
        return companions?.first?.color
    }

    static var previewSample: CustomUnit {
        let customUnit = CustomUnit(context: PersistenceController.preview.viewContext)
        customUnit.name = "Spoon"
        customUnit.substanceName = "Ketamine"
        customUnit.originalUnit = "mg"
        customUnit.unit = "scoop"
        customUnit.isEstimate = false
        customUnit.dose = 30
        customUnit.note = "Some random notes"
        return customUnit
    }

    static var unknownDoseSample: CustomUnit {
        let customUnit = CustomUnit(context: PersistenceController.preview.viewContext)
        customUnit.name = "Line"
        customUnit.substanceName = "Ketamine"
        customUnit.originalUnit = "mg"
        customUnit.unit = "line"
        customUnit.dose = 0
        customUnit.note = "Some random notes"
        return customUnit
    }

    static var estimatePreviewSample: CustomUnit {
        let customUnit = CustomUnit(context: PersistenceController.preview.viewContext)
        customUnit.name = "Estimated"
        customUnit.substanceName = "Ketamine"
        customUnit.originalUnit = "mg"
        customUnit.unit = "line"
        customUnit.dose = 20
        customUnit.isEstimate = true
        customUnit.note = "Some random notes"
        return customUnit
    }

    static var estimatedQuantitativelyPreviewSample: CustomUnit {
        let customUnit = CustomUnit(context: PersistenceController.preview.viewContext)
        customUnit.name = "Estimated Quantitatively"
        customUnit.substanceName = "Ketamine"
        customUnit.originalUnit = "mg"
        customUnit.unit = "line"
        customUnit.dose = 20
        customUnit.isEstimate = true
        customUnit.estimatedDoseVariance = 2
        customUnit.note = "Some random notes"
        return customUnit
    }
}
