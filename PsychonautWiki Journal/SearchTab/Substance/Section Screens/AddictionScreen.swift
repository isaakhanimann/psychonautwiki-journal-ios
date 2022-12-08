//
//  AddictionScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct AddictionScreen: View {
    let addictionPotential: String
    
    var body: some View {
        List {
            Section {
                Text(addictionPotential)
            }
        }.navigationTitle("Addiction Potential")
    }
}

struct AddictionScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddictionScreen(addictionPotential: SubstanceRepo.shared.getSubstance(name: "MDMA")!.addictionPotential!)
    }
}
