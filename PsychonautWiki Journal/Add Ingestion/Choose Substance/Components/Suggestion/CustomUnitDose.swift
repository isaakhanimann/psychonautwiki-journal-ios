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

struct CustomUnitDose: Equatable, Identifiable {

    var id: String {
        "\(dose)\(isEstimate)\(customUnit.description)"
    }

    let dose: Double
    let isEstimate: Bool
    let estimatedStandardDeviation: Double?
    let customUnit: CustomUnit

    // https://en.m.wikipedia.org/wiki/Distribution_of_the_product_of_two_random_variables
    // E(X*Y) = E(X) * E(Y)
    var calculatedDose: Double? {
        if let dosePerUnit = customUnit.doseUnwrapped {
            return dose * dosePerUnit
        } else {
            return nil
        }
    }

    // https://www.mathsisfun.com/data/standard-deviation.html
    // https://en.m.wikipedia.org/wiki/Distribution_of_the_product_of_two_random_variables
    // Var(X*Y) = (Var(X) + E(X)^2)*(Var(Y) + E(Y)^2) - E(X)^2 * E(Y)^2
    var calculatedStandardDeviation: Double? {
        if let expectationY = customUnit.doseUnwrapped {
            let standardDeviationY = customUnit.isEstimate ? (customUnit.estimatedDoseStandardDeviationUnwrapped ?? 0) : 0
            let expectationX = dose
            let standardDeviationX = isEstimate ? (estimatedStandardDeviation ?? 0) : 0
            let sum1 = pow(standardDeviationX, 2) + pow(expectationX, 2)
            let sum2 = pow(standardDeviationY, 2) + pow(expectationY, 2)
            let expectations = pow(expectationX, 2) * pow(expectationY, 2)
            let productVariance = sum1*sum2 - expectations
            if productVariance > 0.0000001 {
                return sqrt(productVariance)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    // 20 mg
    var calculatedDoseDescription: String? {
        if let calculatedDose {
            if let calculatedStandardDeviation {
                return "\(calculatedDose.asRoundedReadableString)±\(calculatedStandardDeviation.asRoundedReadableString) \(customUnit.originalUnitUnwrapped)"
            } else {
                let description = "\(calculatedDose.asRoundedReadableString) \(customUnit.originalUnitUnwrapped)"
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

    // 2 pills
    var doseDescription: String {
        let description = dose.with(pluralizableUnit: customUnit.pluralizableUnit)
        if isEstimate {
            if let estimatedStandardDeviation {
                return "\(dose.asRoundedReadableString)±\(estimatedStandardDeviation.asRoundedReadableString) \(dose.justUnit(pluralizableUnit: customUnit.pluralizableUnit))"
            } else {
                return "~\(description)"
            }
        } else {
            return description
        }
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.calculatedDoseDescription == rhs.calculatedDoseDescription && lhs.doseDescription == rhs.doseDescription
    }
}
