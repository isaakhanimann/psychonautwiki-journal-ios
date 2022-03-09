import SwiftUI

struct AcknowledgeInteractionsView: View {

    let substance: Substance
    let dismiss: () -> Void
    let experience: Experience?

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                InteractionsSection(substance: substance)
            }
            NavigationLink(
                destination: ChooseRouteView(
                    substance: substance,
                    dismiss: dismiss,
                    experience: experience
                ),
                label: {
                    Text("Next")
                        .primaryButtonText()
                }
            )
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel", action: dismiss)
            }
        }
        .navigationBarTitle(substance.nameUnwrapped)
    }
}

struct AcknowledgeInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgeInteractionsView(
            substance: PreviewHelper.shared.getSubstance(with: "Caffeine")!,
            dismiss: {},
            experience: nil
        )
    }
}
