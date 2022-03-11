import SwiftUI

struct SubstanceInteractionsSection: View {

    let substanceInteractable: SubstanceInteractable

    var body: some View {
        Group {
            if !substanceInteractable.dangerousSubstancesToShow.isEmpty {
                Section("Dangerous Interactions (not exhaustive)") {
                    ForEach(substanceInteractable.dangerousSubstancesToShow) { sub in
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            InteractionLabel(text: sub.nameUnwrapped, interactionType: .dangerous)
                        }
                    }
                }
            }
            if !substanceInteractable.unsafeSubstancesToShow.isEmpty {
                Section("Unsafe Interactions (not exhaustive)") {
                    ForEach(substanceInteractable.unsafeSubstancesToShow) { sub in
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            InteractionLabel(text: sub.nameUnwrapped, interactionType: .unsafe)
                        }
                    }
                }
            }
            if !substanceInteractable.uncertainSubstancesToShow.isEmpty {
                Section("Uncertain Interactions (not exhaustive)") {
                    ForEach(substanceInteractable.uncertainSubstancesToShow) { sub in
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            InteractionLabel(text: sub.nameUnwrapped, interactionType: .uncertain)
                        }
                    }
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
