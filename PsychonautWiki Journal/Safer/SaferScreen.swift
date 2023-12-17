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
        NavigationStack {
            List {
                Section {
                    let title1 = "Research"
                    NavigationLink(title1) {
                        List {
                            Text("In advance research the duration, subjective effects and potential adverse effects which the substance or combination of substances are likely to produce.\nRead the info in here and also the PsychonautWiki article. Its best to cross-reference with other sources (Tripsit, Erowid, Wikipedia, Bluelight, Reddit, etc).\nThere is no rush.")
                        }
                        .navigationTitle(title1)
                        .dismissWhenTabTapped()
                    }
                    NavigationLink("Testing") {
                        TestingScreen()
                    }
                    NavigationLink("Dosage") {
                        HowToDoseScreen()
                    }
                    let title4 = "Set and Setting"
                    NavigationLink(title4) {
                        List {
                            Section("Set") {
                                Text("Make sure your thoughts, desires, feelings, general mood, and any preconceived notions or expectations about what you are about to experience are conducive to the experience. Make sure your body is well. Better not to take it if you feel sick, injured or generally unhealthy.")
                            }
                            Section("Setting") {
                                Text("An unfamiliar, uncontrollable or otherwise disagreeable social or physical environment may result in an unpleasant or dangerous experience. Choose an environment that provides a sense of safety, familiarity, control, and comfort. For using hallucinogens (psychedelics, dissociatives and deliriants) refer to the safer hallucinogen guide.")
                            }
                            NavigationLink("Safer Hallucinogen Guide") {
                                SaferHallucinogenScreen()
                            }
                        }
                        .navigationTitle(title4)
                        .dismissWhenTabTapped()
                    }
                    let title5 = "Combinations"
                    NavigationLink(title5) {
                        List {
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
                        .navigationTitle(title5)
                            .dismissWhenTabTapped()
                    }
                    NavigationLink("Administration Routes") {
                        SaferRoutesScreen()
                    }
                    Group {
                        let title7 = "Allergy Tests"
                        NavigationLink(title7) {
                            List {
                                Text("Simply dose a minuscule amount of the substance (e.g. 1/10 to 1/4 of a regular dose) and wait several hours to verify that you do not exhibit an unusual or idiosyncratic response.")
                            }
                            .navigationTitle(title7)
                            .dismissWhenTabTapped()
                        }
                        let title8 = "Reflection"
                        NavigationLink(title8) {
                            List {
                                Text("Carefully monitor the frequency and intensity of any substance use to ensure it is not sliding into abuse and addiction. In particular, many stimulants, opioids, and depressants are known to be highly addictive.")
                            }
                            .navigationTitle(title8)
                            .dismissWhenTabTapped()
                        }
                        let title9 = "Safety of Others"
                        NavigationLink(title9) {
                            List {
                                Text("Don’t drive, operate heavy machinery, or otherwise be directly or indirectly responsible for the safety or care of another person while intoxicated.")
                            }
                            .navigationTitle(title9)
                            .dismissWhenTabTapped()
                        }
                        let title10 = "Recovery Position"
                        NavigationLink(title10) {
                            List {
                                Text("If someone is unconscious and breathing place them into Recovery Position to prevent death by the suffocation of vomit after a drug overdose.\nHave the contact details of help services to hand in case of urgent need.")
                                Link(destination: URL(string: "https://www.youtube.com/watch?v=dv3agW-DZ5I")!
                                ) {
                                    Label("Recovery Position Video", systemImage: "play")
                                }
                            }
                            .navigationTitle(title10)
                            .dismissWhenTabTapped()
                        }
                    }
                }
                Section {
                    NavigationLink(destination: SprayCalculatorScreen()) {
                        Label("Spray Calculator", systemImage: "eyedropper")
                    }
                }
            }
            .font(.headline)
            .navigationTitle("Safer Use")
        }
    }
}

struct SaferTab_Previews: PreviewProvider {
    static var previews: some View {
        SaferScreen().headerProminence(.increased)
    }
}
