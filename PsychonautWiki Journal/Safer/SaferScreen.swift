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
            Section("Research") {
                Text("In advance research the duration, subjective effects and potential adverse effects which the substance or combination of substances are likely to produce.\nRead the info in here and also the PsychonautWiki article. Its best to cross-reference with other sources (Tripsit, Erowid, Wikipedia, Bluelight, Reddit, etc).\nThere is no rush.")
            }
            Section("Testing") {
                Text("Test your substance with anonymous and free drug testing services. If those are not available in your country, use reagent testing kits. Don‘t trust your dealer to sell reliable product. Its better to have a tested stash instead of relying on a source spontaneously.")
                NavigationLink("Drug Testing Services", value: GlobalNavigationDestination.testingServices)
                NavigationLink("Reagent Testing", value: GlobalNavigationDestination.reagentTesting)
            }
            Section("Dosage") {
                Text("Know your dose, start small and wait. A full stomach can delay the onset of a swallowed ingestion by hours. A dose that's light for somebody with a tolerance might be too much for you.\n\nInvest in a milligram scale so you can accurately weigh your dosages. Bear in mind that milligram scales under $1000 cannot accurately weigh out doses below 50 mg and are highly inaccurate under 10 - 15 mg. If the amounts of the drug are smaller, use volumetric dosing (dissolving in water or alcohol to make it easier to measure).\n\nMany substances do not have linear dose-response curves, meaning that doubling the dose amount will cause a greater than double increase (and rapidly result in overwhelming, unpleasant, and potentially dangerous experiences), therefore doses should only be adjusted upward with slight increases (e.g. 1/4 to 1/2 of the previous dose).")
                NavigationLink("Dosage Guide", value: GlobalNavigationDestination.doseGuide)
                NavigationLink("Dosage Classification", value: GlobalNavigationDestination.doseClassification)
                NavigationLink("Volumetric Liquid Dosing", value: GlobalNavigationDestination.volumetricDosing)
            }
            Section("Set") {
                Text("Make sure your thoughts, desires, feelings, general mood, and any preconceived notions or expectations about what you are about to experience are conducive to the experience. Make sure your body is well. Better not to take it if you feel sick, injured or generally unhealthy.")
            }
            Section("Setting") {
                Text("An unfamiliar, uncontrollable or otherwise disagreeable social or physical environment may result in an unpleasant or dangerous experience. Choose an environment that provides a sense of safety, familiarity, control, and comfort. For using hallucinogens (psychedelics, dissociatives and deliriants) refer to the safer hallucinogen guide.")
            }
            NavigationLink("Safer Hallucinogen Guide", value: GlobalNavigationDestination.saferHallucinogen)
            Section("Combinations") {
                Text("Don’t combine drugs, including Alcohol, without research on the combo. The most common cause of substance-related deaths is the combination of depressants (such as opiates, benzodiazepines, or alcohol) with other depressants.")
                Link(
                    "Swiss Combination Checker",
                    destination: URL(string: "https://combi-checker.ch")!
                )
                Link(
                    "Tripsit Combination Checker",
                    destination: URL(string: "https://combo.tripsit.me")!
                )
            }
            Section("Administration Routes") {
                SaferRoutesSectionContent()
            }
            Group {
                Section("Allergy Tests") {
                    Text("Simply dose a minuscule amount of the substance (e.g. 1/10 to 1/4 of a regular dose) and wait several hours to verify that you do not exhibit an unusual or idiosyncratic response.")
                }
                Section("Reflection") {
                    Text("Carefully monitor the frequency and intensity of any substance use to ensure it is not sliding into abuse and addiction. In particular, many stimulants, opioids, and depressants are known to be highly addictive.")
                }
                Section("Safety of Others") {
                    Text("Don’t drive, operate heavy machinery, or otherwise be directly or indirectly responsible for the safety or care of another person while intoxicated.")
                }
                Section("Recovery Position") {
                    Text("If someone is unconscious and breathing place them into Recovery Position to prevent death by the suffocation of vomit after a drug overdose.\nHave the contact details of help services to hand in case of urgent need.")
                    Link(destination: URL(string: "https://www.youtube.com/watch?v=dv3agW-DZ5I")!
                    ) {
                        Label("Recovery Position Video", systemImage: "play")
                    }
                }
            }
            Section {
                NavigationLink(value: GlobalNavigationDestination.sprayCalculator) {
                    Label("Spray Calculator", systemImage: "eyedropper").font(.headline)
                }
            }
        }
        .navigationTitle("Safer Use")
    }
}

#Preview {
    SaferScreen()
}
