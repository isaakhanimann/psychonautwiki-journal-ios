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
                .font(.headline)
                .multilineTextAlignment(.center)
            Spacer().frame(height: 2)
            VStack(alignment: .leading) {
                ForEach(interactions) { interaction in
                    HStack {
                        Text(interaction.name).foregroundColor(interaction.interactionType.color)
                        Spacer()
                        DangerTriangles(interactionType: interaction.interactionType)
                    }
                }
            }
            .font(.subheadline.bold())
        }
    }
}

struct InteractionHudContent_Previews: PreviewProvider {
    static var previews: some View {
        Hud {
            InteractionHudContent(substanceName: "MDMA", interactions: [
                InteractionWith(name: "MAOI", interactionType: .dangerous),
                InteractionWith(name: "5-Hydroxytryptophan", interactionType: .dangerous),
                InteractionWith(name: "SSRIs", interactionType: .unsafe),
                InteractionWith(name: "SNRIs", interactionType: .unsafe),
                InteractionWith(name: "Alcohol", interactionType: .uncertain),
                InteractionWith(name: "Caffeine", interactionType: .uncertain)
            ])
        }
    }
}
