//
//  InteractionPairRow.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 27.12.22.
//

import SwiftUI

struct InteractionPairRow: View {

    let aName: String
    let bName: String
    let interactionType: InteractionType

    var body: some View {
        HStack(spacing: 0) {
            Text(aName)
            Spacer()
            Image(systemName: "arrow.left.arrow.right")
            Spacer()
            Text(bName)
            Spacer()
            ForEach(0..<interactionType.dangerCount, id: \.self) { _ in
                Image(systemName: "exclamationmark.triangle")
            }
        }.foregroundColor(interactionType.color)
    }
}

struct InteractionPairRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            InteractionPairRow(
                aName: "Amphetamine with a long name",
                bName: "Tramadol",
                interactionType: .dangerous
            )
        }
    }
}
