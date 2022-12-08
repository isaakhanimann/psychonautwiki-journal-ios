//
//  EffectScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct EffectScreen: View {
    let effect: String
    var body: some View {
        List {
            Section {
                Text(effect)
            }
        }.navigationTitle("Effects")
    }
}

struct EffectScreen_Previews: PreviewProvider {
    static var previews: some View {
        EffectScreen(effect: SubstanceRepo.shared.getSubstance(name: "MDMA")!.effectsSummary!)
    }
}
