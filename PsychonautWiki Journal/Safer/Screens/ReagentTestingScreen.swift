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

struct ReagentTestingScreen: View {
    var body: some View {
        List {
            Text("Reagent testing kits is a drug testing method that uses chemical solutions that change in color when applied to a chemical compound. They can help determine what chemical might be present in a given sample. In many cases they do not rule out the possibility of another similar compound being present in addition to or instead of the one suspected.\n\nAlthough very few substances are effective at dosages that allow the use of paper blotters, LSD is not the only one: It's essential to test for its presence to avoid substances of the NBOMe class. Additionally, it's becoming increasingly important to test for possible Fentanyl contamination, since this substance is effective at dosages that make it possible to put very high quantities on a single blotter.\n\nReagents can only determine the presence, not the quantity or purity, of a particular substance. Dark color reactions will tend to override reactions to other substances also in the pill. A positive or negative reaction for a substance does not indicate that a drug is safe. No drug use is 100% safe. Make wise decisions and take responsibility for your health and well-being; no one else can.")
            Section("Kit Sellers") {
                Link("DanceSafe", destination: URL(string: "https://dancesafe.org/testing-kit-instructions/")!)
                Link("Bunk Police", destination: URL(string: "https://bunkpolice.com")!)
            }
        }
        .navigationTitle("Reagent Testing")
    }
}

#Preview {
    NavigationStack {
        ReagentTestingScreen()
    }
}
