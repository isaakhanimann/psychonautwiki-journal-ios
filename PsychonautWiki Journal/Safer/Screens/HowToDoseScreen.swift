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

struct HowToDoseScreen: View {
    var body: some View {
        List {
            Text("Know your dose, start small and wait. A full stomach can delay the onset of a swallowed ingestion by hours. A dose that's light for somebody with a tolerance might be too much for you.\n\nInvest in a milligram scale so you can accurately weigh your dosages. Bear in mind that milligram scales under $1000 cannot accurately weigh out doses below 50 mg and are highly inaccurate under 10 - 15 mg. If the amounts of the drug are smaller, use volumetric dosing (dissolving in water or alcohol to make it easier to measure).\n\nMany substances do not have linear dose-response curves, meaning that doubling the dose amount will cause a greater than double increase (and rapidly result in overwhelming, unpleasant, and potentially dangerous experiences), therefore doses should only be adjusted upward with slight increases (e.g. 1/4 to 1/2 of the previous dose).")
            NavigationLink("Dosage Guide", value: GlobalNavigationDestination.doseGuide)
            NavigationLink("Dosage Classification", value: GlobalNavigationDestination.doseClassification)
            NavigationLink("Volumetric Liquid Dosing", value: GlobalNavigationDestination.volumetricDosing)
        }
        .navigationTitle("Dosage")
    }
}

#Preview {
    NavigationStack {
        HowToDoseScreen()
    }
}
