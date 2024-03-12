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

// MARK: - InteractionsGroup

struct InteractionsGroup: View {
    let interactions: Interactions
    let substance: Substance

    var body: some View {
        Group {
            ForEach(interactions.dangerous, id: \.self) { name in
                LinkOrLabel(substance: substance) {
                    HStack {
                        Text(name)
                        Spacer()
                        DangerTriangles(interactionType: .dangerous)
                    }.foregroundColor(InteractionType.dangerous.color)
                }
            }
            ForEach(interactions.unsafe, id: \.self) { name in
                LinkOrLabel(substance: substance) {
                    HStack {
                        Text(name)
                        Spacer()
                        DangerTriangles(interactionType: .unsafe)
                    }.foregroundColor(InteractionType.unsafe.color)
                }
            }
            ForEach(interactions.uncertain, id: \.self) { name in
                LinkOrLabel(substance: substance) {
                    HStack {
                        Text(name)
                        Spacer()
                        DangerTriangles(interactionType: .uncertain)
                    }.foregroundColor(InteractionType.uncertain.color)
                }
            }
        }
    }
}

// MARK: - LinkOrLabel

private struct LinkOrLabel<Label: View>: View {

    let substance: Substance
    let label: () -> Label

    var body: some View {
        if let interactionURL = URL(string: substance.url.absoluteString + "#Dangerous_interactions") {
            NavigationLink(value: GlobalNavigationDestination.webViewInteractions(substanceName: substance.name, articleURL: interactionURL)) {
                label()
            }
        }
    }
}

private let substance = SubstanceRepo.shared.getSubstance(name: "MDMA")!
#Preview {
    List {
        Section {
            InteractionsGroup(
                interactions: substance.interactions!,
                substance: substance)
        }
    }
}
