//
//  SaferUseScreen.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 08.12.22.
//

import SwiftUI

struct SaferUseScreen: View {
    let saferUse: [String]
    var body: some View {
        List {
            Section {
                ForEach(saferUse, id: \.self) { point in
                    Text(point)
                }
            }
        }.navigationTitle("Safer Use")
    }
}

struct SaferUseScreen_Previews: PreviewProvider {
    static var previews: some View {
        SaferUseScreen(saferUse: SubstanceRepo.shared.getSubstance(name: "MDMA")!.saferUse)
    }
}
