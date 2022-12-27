//
//  SaferTab.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 06.12.22.
//

import SwiftUI

struct SaferScreen: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                let title1 = "1. Research"
                NavigationLink(title1) {
                    List {
                        Text("In advance research the duration, subjective effects and potential adverse effects which the substance or combination of substances are likely to produce.\nRead the info in here and also the PsychonautWiki article. Its best to cross-reference with other sources (Tripsit, Erowid, Wikipedia, Bluelight, Reddit, etc).\nThere is no rush.")
                    }.navigationTitle(title1)
                }
                let title2 = "2. Testing"
                NavigationLink(title2) {
                    List {
                        Text("Test your substance with anonymous and free drug testing services. If those are not available in your country, use reagent testing kits. Don‘t trust your dealer to sell reliable product. Its better to have a tested stash instead of relying on a source spontaneously.")
                        NavigationLink("Drug Testing Services") {
                            TestingServicesScreen()
                        }
                        NavigationLink("Reagent Testing") {
                            ReagentTestingScreen()
                        }
                    }.navigationTitle(title2)
                }
                let title3 = "3. Dosage"
                NavigationLink(title3) {
                    List {
                        Text("You can always take more, but you can’t take less. Know your dose, start small and wait. A full stomach can delay the onset of a swallowed ingestion by hours. A dose that's easy for somebody with a tolerance might be too much for you.\n\nInvest in a milligram scale so you can accurately weigh your dosages. Bear in mind that milligram scales under $1000 cannot accurately weigh out doses below 50 mg and are highly inaccurate under 10 - 15 mg. If the amounts of the drug are smaller, use volumetric dosing (dissolving in water or alcohol to make it easier to measure).\n\nMany substances do not have linear dose-response curves, meaning that doubling the dose amount will cause a greater than double increase (and rapidly result in overwhelming, unpleasant, and potentially dangerous experiences), therefore doses should only be adjusted upward with slight increases (e.g. 1/4 to 1/2 of the previous dose).")
                        NavigationLink("Dosage Guide") {
                            DosageGuideScreen()
                        }
                        NavigationLink("Dosage Classification") {
                            DosageClassificationScreen()
                        }
                        NavigationLink("Volumetric Liquid Dosing") {
                            VolumetricDosingScreen()
                        }
                    }.navigationTitle(title3)
                }
                let title4 = "4. Set and Setting"
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
                    .headerProminence(.increased)
                    .navigationTitle(title4)
                }
                let title5 = "5. Combinations"
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
                    }.navigationTitle(title5)
                }
                let title6 = "6. Administration Routes"
                NavigationLink(title6) {
                    List {
                        Text("Don’t share snorting equipment (straws, banknotes, bullets) to avoid blood-borne diseases such as Hepatitis C that can be transmitted through blood amounts so small you can’t notice. Injection is the the most dangerous route of administration and highly advised against. If you are determined to inject, don’t share injection materials and refer to the safer injection guide.")
                        Link(
                            "Safer Snorting",
                            destination: URL(string: "https://www.youtube.com/watch?v=31fuvYXxeV0&list=PLkC348-BeCu6Ut-iJy8xp9_LLKXoMMroR")!
                        )
                        Link(
                            "Safer Smoking",
                            destination: URL(string: "https://www.youtube.com/watch?v=lBlS2e46CV0&list=PLkC348-BeCu6Ut-iJy8xp9_LLKXoMMroR")!
                        )
                        Link(
                            "Safer Injecting",
                            destination: URL(string: "https://www.youtube.com/watch?v=N7HjCPz4A7Y&list=PLkC348-BeCu6Ut-iJy8xp9_LLKXoMMroR")!
                        )
                        NavigationLink("Administration Routes Info") {
                            AdministrationRouteScreen()
                        }
                    }.navigationTitle(title6)
                }
                Group {
                    let title7 = "7. Allergy Tests"
                    NavigationLink(title7) {
                        List {
                            Text("Simply dose a minuscule amount of the substance (e.g. 1/10 to 1/4 of a regular dose) and wait several hours to verify that you do not exhibit an unusual or idiosyncratic response.")
                        }.navigationTitle(title7)
                    }
                    let title8 = "8. Reflection"
                    NavigationLink(title8) {
                        List {
                            Text("Carefully monitor the frequency and intensity of any substance use to ensure it is not sliding into abuse and addiction. In particular, many stimulants, opioids, and depressants are known to be highly addictive.")
                        }.navigationTitle(title8)
                    }
                    let title9 = "9. Safety of Others"
                    NavigationLink(title9) {
                        List {
                            Text("Don’t drive, operate heavy machinery, or otherwise be directly or indirectly responsible for the safety or care of another person while intoxicated.")
                        }.navigationTitle(title9)
                    }
                    let title10 = "10. Recovery Position"
                    NavigationLink(title10) {
                        List {
                            Text("If someone is unconscious and breathing place them into Recovery Position to prevent death by the suffocation of vomit after a drug overdose.\nHave the contact details of help services to hand in case of urgent need.")
                            Link(
                                "Recovery Position Video",
                                destination: URL(string: "https://www.youtube.com/watch?v=dv3agW-DZ5I")!
                            )
                        }.navigationTitle(title10)
                    }
                }
            }
            .navigationTitle("Safer Use")
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SaferTab_Previews: PreviewProvider {
    static var previews: some View {
        SaferScreen()
    }
}
