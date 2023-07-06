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

import SwiftUI

struct ToleranceChartExplanationScreen: View {

    var body: some View {
        ScrollView {
            Text(chartExplanation)
                .padding(.horizontal)
        }
        .navigationTitle("Chart Explanation")
        .dismissWhenTabTapped()
    }

    private let chartExplanation = "Marked by an opaque hue, the phase directly succeeding consumption reflects an elevated tolerance to the particular substance. The subsequent lighter shade indicates a reduced tolerance level. This is followed by a return to zero tolerance, necessitating dosage adjustments akin to initial consumption.\n\nThis chart does not factor in cross tolerances.\n\nThe start date denotes the earliest ingestion taken into consideration.\nThe vertical line corresponds to the present time.\n\nThis chart is intended to provide basic guidance. For many substances full tolerance only develops after prolonged and repeated use. In the scenario of repeated heavy doses, it may require a lengthier duration for tolerance to fully reset. It is safer to begin with a small dose, especially after a break in consumption. For more detailed information to the tolerance of the substance in question, read the PsychonautWiki article."

}

struct ToleranceChartExplanationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ToleranceChartExplanationScreen()
        }
    }
}
