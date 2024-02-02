// Copyright (c) 2024. Isaak Hanimann.
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

struct CustomUnitDose: Hashable, Identifiable {

    var id: String {
        "\(dose)\(isEstimate)\(customUnit.description)"
    }

    let dose: Double
    let isEstimate: Bool
    let estimatedDoseVariance: Double?
    let customUnit: CustomUnit

    var calculatedDose: Double? {
        guard let dosePerUnit = customUnit.doseUnwrapped else { return nil }
        if let customDoseVariance = customUnit.estimatedDoseVarianceUnwrapped, let estimatedDoseVariance, isEstimate {
            let minDose = dose - estimatedDoseVariance
            let maxDose = dose + estimatedDoseVariance
            let minCustomDose = dosePerUnit - customDoseVariance
            let maxCustomDose = dosePerUnit + customDoseVariance
            let minResult = minDose * minCustomDose
            let maxResult = maxDose * maxCustomDose
            let result = (minResult + maxResult) / 2
            return result
        } else {
            return dose * dosePerUnit
        }
    }

    var calculatedDoseVariance: Double? {
        guard let dosePerUnit = customUnit.doseUnwrapped else { return nil }
        if let customDoseVariance = customUnit.estimatedDoseVarianceUnwrapped { // estimated custom dose
            if let estimatedDoseVariance, isEstimate { // estimated dose
                let minDose = dose - estimatedDoseVariance
                let maxDose = dose + estimatedDoseVariance
                let minCustomDose = dosePerUnit - customDoseVariance
                let maxCustomDose = dosePerUnit + customDoseVariance
                let minResult = minDose * minCustomDose
                let maxResult = maxDose * maxCustomDose
                let result = (minResult + maxResult) / 2
                let resultVariance = maxResult - result
                return resultVariance
            } else { // estimated custom dose, non estimated dose
                return dose * customDoseVariance
            }
        } else { // non estimated custom dose
            if let estimatedDoseVariance, isEstimate { // non estimated custom dose, estimated dose
                return estimatedDoseVariance * dosePerUnit
            } else { // non estimated custom dose, non estimated dose
                return nil
            }
        }
    }

    var calculatedDoseDescription: String? {
        if let calculatedDose {
            if let calculatedDoseVariance {
                return "\(calculatedDose.formatted())±\(calculatedDoseVariance.formatted()) \(customUnit.originalUnitUnwrapped)"
            } else {
                let description = "\(calculatedDose.formatted()) \(customUnit.originalUnitUnwrapped)"
                if isEstimate || customUnit.isEstimate {
                    return "~\(description)"
                } else {
                    return description
                }
            }
        } else {
            return nil
        }
    }

    var doseDescription: String {
        let description = "\(dose.with(unit: customUnit.unitUnwrapped))"
        if isEstimate {
            if let estimatedDoseVariance {
                return "\(dose.formatted())±\(estimatedDoseVariance.with(unit: customUnit.unitUnwrapped))"
            } else {
                return "~\(description)"
            }
        } else {
            return description
        }
    }
}
