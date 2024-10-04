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

import SwiftUI

// https://online.stat.psu.edu/stat200/lesson/2/2.2/2.2.7#:~:text=The%2095%25%20Rule%20states%20that,mean%20on%20a%20normal%20distribution
enum StandardDeviationConfidenceIntervals {
    static func getOneStandardDeviationText(mean: Double, standardDeviation: Double, unit: String) -> String {
        let lowerRange = mean - standardDeviation
        let higherRange = mean + standardDeviation
        return "\(lowerRange.asRoundedReadableString)-\(higherRange.asRoundedReadableString) \(unit) in 68% of cases"
    }

    static func getTwoStandardDeviationText(mean: Double, standardDeviation: Double, unit: String) -> String {
        let twoStandardDeviations = 2*standardDeviation
        let lowerRange = mean - twoStandardDeviations
        let higherRange = mean + twoStandardDeviations
        return "\(lowerRange.asRoundedReadableString)-\(higherRange.asRoundedReadableString) \(unit) in 95% of cases"
    }
}

struct StandardDeviationConfidenceIntervalExplanation: View {

    let mean: Double
    let standardDeviation: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(mean.formatted())±\(standardDeviation.formatted()) \(unit) means:")
            Text(StandardDeviationConfidenceIntervals.getOneStandardDeviationText(mean: mean, standardDeviation: standardDeviation, unit: unit))
            Text(StandardDeviationConfidenceIntervals.getTwoStandardDeviationText(mean: mean, standardDeviation: standardDeviation, unit: unit))
        }.foregroundStyle(.secondary)
    }
}
