import SwiftUI

struct InteractionsSection: View {

    let substance: Substance

    var body: some View {
        Section("Interactions (Not Exhaustive)") {
            Group {
                ForEach(substance.dangerousPsychoactivesToShow) { psych in
                    NavigationLink {
                        PsychoactiveView(psychoactive: psych)
                    } label: {
                        InteractionLabel(text: psych.nameUnwrapped, interactionType: .dangerous)
                    }
                }
                ForEach(substance.dangerousChemicalsToShow) { chem in
                    NavigationLink {
                        ChemicalView(chemical: chem)
                    } label: {
                        InteractionLabel(text: chem.nameUnwrapped, interactionType: .dangerous)
                    }
                }
                ForEach(substance.dangerousSubstancesToShow) { sub in
                    NavigationLink {
                        SubstanceView(substance: sub)
                    } label: {
                        InteractionLabel(text: sub.nameUnwrapped, interactionType: .dangerous)
                    }
                }
                ForEach(substance.dangerousUnresolvedsToShow) { unr in
                    NavigationLink {
                        UnresolvedView(unresolved: unr)
                    } label: {
                        InteractionLabel(text: unr.nameUnwrapped, interactionType: .dangerous)
                    }
                }
            }
            Group {
                ForEach(substance.unsafePsychoactivesToShow) { psych in
                    NavigationLink {
                        PsychoactiveView(psychoactive: psych)
                    } label: {
                        InteractionLabel(text: psych.nameUnwrapped, interactionType: .unsafe)
                    }
                }
                ForEach(substance.unsafeChemicalsToShow) { chem in
                    NavigationLink {
                        ChemicalView(chemical: chem)
                    } label: {
                        InteractionLabel(text: chem.nameUnwrapped, interactionType: .unsafe)
                    }
                }
                ForEach(substance.unsafeSubstancesToShow) { sub in
                    NavigationLink {
                        SubstanceView(substance: sub)
                    } label: {
                        InteractionLabel(text: sub.nameUnwrapped, interactionType: .unsafe)
                    }
                }
                ForEach(substance.unsafeUnresolvedsToShow) { unr in
                    NavigationLink {
                        UnresolvedView(unresolved: unr)
                    } label: {
                        InteractionLabel(text: unr.nameUnwrapped, interactionType: .unsafe)
                    }
                }
            }
            Group {
                ForEach(substance.uncertainPsychoactivesToShow) { psych in
                    NavigationLink {
                        PsychoactiveView(psychoactive: psych)
                    } label: {
                        InteractionLabel(text: psych.nameUnwrapped, interactionType: .uncertain)
                    }
                }
                ForEach(substance.uncertainChemicalsToShow) { chem in
                    NavigationLink {
                        ChemicalView(chemical: chem)
                    } label: {
                        InteractionLabel(text: chem.nameUnwrapped, interactionType: .uncertain)
                    }
                }
                ForEach(substance.uncertainSubstancesToShow) { sub in
                    NavigationLink {
                        SubstanceView(substance: sub)
                    } label: {
                        InteractionLabel(text: sub.nameUnwrapped, interactionType: .uncertain)
                    }
                }
                ForEach(substance.uncertainUnresolvedsToShow) { unr in
                    NavigationLink {
                        UnresolvedView(unresolved: unr)
                    } label: {
                        InteractionLabel(text: unr.nameUnwrapped, interactionType: .uncertain)
                    }
                }
            }
        }
    }
}

struct InteractionsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            InteractionsSection(substance: PreviewHelper.shared.getSubstance(with: "Caffeine")!)
        }
    }
}
