// Copyright (c) 2023. Isaak Hanimann.
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

struct InteractionHudContent: View {
    let substanceName: String
    let interactions: [InteractionWith]

    var body: some View {
        VStack {
            Text("\(substanceName) Interactions")
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
            Spacer().frame(height: 3)
            HStack {
                VStack(alignment: .trailing) {
                    ForEach(interactions) { interaction in
                        DangerTriangles(interactionType: interaction.interactionType)
                    }
                }
                VStack(alignment: .leading) {
                    ForEach(interactions) { interaction in
                        Text(interaction.name).foregroundColor(interaction.interactionType.color)
                    }
                }
            }
            .font(.headline)
        }
    }
}

struct InteractionHudContent_Previews: PreviewProvider {
    static var previews: some View {
        Hud {
            InteractionHudContent(substanceName: "My Substance Long Name", interactions: [
                InteractionWith(name: "MDMA", interactionType: .dangerous),
                InteractionWith(name: "Amphetamine", interactionType: .dangerous),
                InteractionWith(name: "Ketamine", interactionType: .unsafe),
                InteractionWith(name: "Alcohol", interactionType: .unsafe),
                InteractionWith(name: "Cannabis", interactionType: .uncertain)
            ])
        }
    }
}
