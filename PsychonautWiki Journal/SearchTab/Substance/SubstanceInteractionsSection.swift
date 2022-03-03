import SwiftUI

struct SubstanceInteractionsSection: View {

    let substanceInteractable: SubstanceInteractable

    var body: some View {
        Section("Interactions (not exhaustive)") {
            ForEach(substanceInteractable.dangerousSubstancesUnwrapped) { sub in
                NavigationLink {
                    SubstanceView(substance: sub)
                } label: {
                    InteractionLabel(text: sub.nameUnwrapped, interactionType: .dangerous)
                }
            }
            ForEach(substanceInteractable.unsafeSubstancesUnwrapped) { sub in
                NavigationLink {
                    SubstanceView(substance: sub)
                } label: {
                    InteractionLabel(text: sub.nameUnwrapped, interactionType: .unsafe)
                }
            }
            ForEach(substanceInteractable.uncertainSubstancesUnwrapped) { sub in
                NavigationLink {
                    SubstanceView(substance: sub)
                } label: {
                    InteractionLabel(text: sub.nameUnwrapped, interactionType: .uncertain)
                }
            }
        }
    }
}

struct SubstanceInteractionsSection_Previews: PreviewProvider {
    static var previews: some View {
        SubstanceInteractionsSection(substanceInteractable: PreviewHelper.shared.substance.psychoactivesUnwrapped[0])
    }
}
