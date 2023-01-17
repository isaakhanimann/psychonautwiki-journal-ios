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
    @State private var isShowingAlert = false
    @State private var interactions: [Interaction] = []

    var body: some View {
        AcknowledgeInteractionsContent(
            substance: substance,
            dismiss: dismiss,
            interactions: interactions,
            isShowingAlert: $isShowingAlert
        ).task {
            let recentIngestions = PersistenceController.shared.getRecentIngestions()
            let names = recentIngestions.map { ing in
                ing.substanceNameUnwrapped
            }
            let allNames = (names + InteractionChecker.additionalInteractionsToCheck).uniqued()
            let interactions = allNames.compactMap { name in
                InteractionChecker.getInteractionBetween(aName: substance.name, bName: name)
            }.uniqued().sorted { int1, int2 in
                int1.interactionType.dangerCount > int2.interactionType.dangerCount
            }
            self.interactions = interactions
            if !interactions.isEmpty {
                isShowingAlert = true
            }
        }
    }
}

struct AcknowledgeInteractionsContent: View {
    
    let substance: Substance
    let dismiss: () -> Void
    let interactions: [Interaction]
    @Binding var isShowingAlert: Bool

    var body: some View {
        if #available(iOS 16.0, *) {
            screen.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    nextLink
                }
            }
        } else {
            screen.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    nextLink
                }
            }
        }
    }

    private var nextLink: some View {
        NavigationLink {
            ChooseRouteScreen(substance: substance, dismiss: dismiss)
        } label: {
            NextLabel()
        }
    }

    var screen: some View {
        ZStack {
            regularContent
                .blur(radius: isShowingAlert ? 10 : 0)
                .allowsHitTesting(!isShowingAlert)
            if isShowingAlert {
                InteractionAlertView(
                    interactions: interactions,
                    substanceName: substance.name,
                    isShowing: $isShowingAlert
                )
            }
        }
    }

    var regularContent: some View {
        List {
            if let interactions = substance.interactions {
                InteractionsGroup(
                    interactions: interactions,
                    substanceURL: substance.url
                )
            } else {
                Text("There are no documented interactions")
            }
        }
        .navigationBarTitle(substance.name + " Interactions")
    }
}


struct AcknowledgeInteractionsContent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(previewDeviceNames, id: \.self) { name in
                NavigationView {
                    AcknowledgeInteractionsContent(
                        substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                        dismiss: {},
                        interactions: [],
                        isShowingAlert: .constant(false)
                    )
                }
                .previewDevice(PreviewDevice(rawValue: name))
                .previewDisplayName(name)
            }
        }
    }
}
