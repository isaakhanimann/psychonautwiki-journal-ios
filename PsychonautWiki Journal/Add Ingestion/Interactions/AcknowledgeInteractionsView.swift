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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .bottomBar) {
                NavigationLink {
                    ChooseRouteScreen(substance: substance, dismiss: dismiss)
                } label: {
                    Label("Next", systemImage: "chevron.forward.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }
            }
        }
        .navigationBarTitle(substance.name + " Interactions")
    }
}

struct AcknowledgeInteractionsContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AcknowledgeInteractionsContent(
                substance: SubstanceRepo.shared.getSubstance(name: "MDMA")!,
                dismiss: {},
                interactions: [],
                isShowingAlert: .constant(false)
            )
        }
    }
}
