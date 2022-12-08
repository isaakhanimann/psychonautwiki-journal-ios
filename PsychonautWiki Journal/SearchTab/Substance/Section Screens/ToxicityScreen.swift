//
//  ToxicityScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct ToxicityScreen: View {
    let toxicities: [String]

    var body: some View {
        List {
            Section {
                ForEach(toxicities, id: \.self) { toxicity in
                    Text(toxicity)
                }
            }
        }
    }
}

struct ToxicityScreen_Previews: PreviewProvider {
    static var previews: some View {
        ToxicityScreen(toxicities: SubstanceRepo.shared.getSubstance(name: "MDMA")!.toxicities)
    }
}
