import SwiftUI

struct AcknowledgeInteractionsView: View {

    let experience: Experience?
    let substance: Substance
    let dismiss: () -> Void

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
        .navigationBarTitle(substance.nameUnwrapped)
    }
}

struct AcknowledgeInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgeInteractionsView(
            experience: nil,
            substance: PreviewHelper.shared.getSubstance(with: "Caffeine")!,
            dismiss: {}
        )
    }
}
