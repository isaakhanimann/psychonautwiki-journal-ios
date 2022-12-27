//
//  TestingScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 23.12.22.
//

import SwiftUI

struct ReagentTestingScreen: View {
    var body: some View {
        List {
            Text("Reagent testing kits is a drug testing method that uses chemical solutions that change in color when applied to a chemical compound. They can help determine what chemical might be present in a given sample. In many cases they do not rule out the possibility of another similar compound being present in addition to or instead of the one suspected.\n\nAlthough very few substances are effective at dosages that allow the use of paper blotters, LSD is not the only one: It's essential to test for its presence to avoid substances of the NBOMe class. Additionally, it's becoming increasingly important to test for possible Fentanyl contamination, since this substance is effective at dosages that make it possible to put very high quantities on a single blotter.\n\nReagents can only determine the presence, not the quantity or purity, of a particular substance. Dark color reactions will tend to override reactions to other substances also in the pill. A positive or negative reaction for a substance does not indicate that a drug is safe. No drug use is 100% safe. Make wise decisions and take responsibility for your health and well-being; no one else can.")
            Section("Kit Sellers") {
                Link("DanceSafe", destination: URL(string: "https://dancesafe.org/testing-kit-instructions/")!)
                Link("Bunk Police", destination: URL(string: "https://bunkpolice.com")!)
            }.headerProminence(.increased)
        }.navigationTitle("Reagent Testing")
    }
}

struct ReagentTestingScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReagentTestingScreen()
        }
    }
}
