//
//  SubstanceBox.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 14.12.22.
//

import SwiftUI

struct SubstanceBox: View {

    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        NavigationLink {
            AcknowledgeInteractionsView(substance: substance, dismiss: dismiss)
        } label: {
            GroupBox(substance.name) {
                Text(substance.commonNames, format: .list(type: .or)).font(.subheadline).foregroundColor(.secondary)
            }
        }

    }
}

struct SubstanceBox_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LazyVStack {
                SubstanceBox(
                    substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                    dismiss: {}
                ).padding(.horizontal)
            }
        }
    }
}
