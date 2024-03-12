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

import SwiftUI

struct SaferScreen: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Research", value: GlobalNavigationDestination.research)
                NavigationLink("Testing", value: GlobalNavigationDestination.testing)
                NavigationLink("Dosage", value: GlobalNavigationDestination.howToDose)
                NavigationLink("Set and Setting", value: GlobalNavigationDestination.setAndSetting)
                NavigationLink("Combinations", value: GlobalNavigationDestination.saferCombinations)
                NavigationLink("Administration Routes", value: GlobalNavigationDestination.saferRoutes)
                Group {
                    NavigationLink("Allergy Tests", value: GlobalNavigationDestination.allergyTests)
                    NavigationLink("Reflection", value: GlobalNavigationDestination.reflection)
                    NavigationLink("Safety of Others", value: GlobalNavigationDestination.safetyOfOthers)
                    NavigationLink("Recovery Position", value: GlobalNavigationDestination.recoveryPosition)
                }
            }
            Section {
                NavigationLink(value: GlobalNavigationDestination.sprayCalculator) {
                    Label("Spray Calculator", systemImage: "eyedropper")
                }
            }
        }
        .font(.headline)
        .navigationTitle("Safer Use")
    }
}

#Preview {
    SaferScreen()
}
