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

struct AcknowledgeSaferUseScreen: View {

    let substance: Substance
    let dismiss: () -> Void

    var body: some View {
        if #available(iOS 16.0, *) {
            screen.toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Cancel") {
                        dismiss()
                    }
                    Spacer()
                    nextLink
                }
            }
        } else {
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
    }

    private var nextLink: some View {
        NavigationLink {
            AcknowledgeInteractionsView(substance: substance, dismiss: dismiss)

        } label: {
            NextLabel()
        }
    }

    var screen: some View {
        List {
            Section {
                ForEach(substance.saferUse, id: \.self) { point in
                    Text(point)
                }
            }
        }.navigationTitle("Safer \(substance.name)")
    }
}

struct AcknowledgeSaferUseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AcknowledgeSaferUseScreen(substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!, dismiss: {})
        }
    }
}
