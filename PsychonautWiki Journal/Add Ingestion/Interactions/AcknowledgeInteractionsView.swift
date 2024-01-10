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

struct AcknowledgeInteractionsView: View {
    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        AcknowledgeInteractionsContent(
            substance: substance,
            dismiss: dismiss
        )
    }
}

struct AcknowledgeInteractionsContent: View {
    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        screen.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                nextLink
            }
        }
    }

    private var screen: some View {
        List {
            if let interactions = substance.interactions {
                InteractionsGroup(
                    interactions: interactions,
                    substance: substance
                )
            } else {
                Text("There are no documented interactions")
            }
        }
        .navigationBarTitle(substance.name + " Interactions")
    }

    private var nextLink: some View {
        NavigationLink(value: ChooseRouteScreenArguments(substance: substance)) {
            NextLabel()
        }
    }
}

#Preview {
    NavigationStack {
        AcknowledgeInteractionsContent(
            substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
            dismiss: {}
        )
    }
}
