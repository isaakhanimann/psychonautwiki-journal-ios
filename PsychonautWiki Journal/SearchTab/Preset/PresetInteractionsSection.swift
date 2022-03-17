import SwiftUI

struct PresetInteractionsSection: View {

    let preset: Preset

    var body: some View {
        Group {
            if !preset.dangerousInteractions.isEmpty {
                Section("Intrinsically Dangerous") {
                    ForEach(preset.dangerousInteractions) { interaction in
                        Text("\(interaction.sub1.nameUnwrapped) is dangerous with \(interaction.sub2.nameUnwrapped)")
                            .foregroundColor(InteractionType.dangerous.color)
                    }
                }
            }
            if !preset.unsafeInteractions.isEmpty {
                Section("Intrinsically Unsafe") {
                    ForEach(preset.unsafeInteractions) { interaction in
                        Text("\(interaction.sub1.nameUnwrapped) is unsafe with \(interaction.sub2.nameUnwrapped)")
                            .foregroundColor(InteractionType.unsafe.color)
                    }
                }
            }
            if !preset.uncertainInteractions.isEmpty {
                Section("Intrinsically Uncertain") {
                    ForEach(preset.uncertainInteractions) { interaction in
                        Text("\(interaction.sub1.nameUnwrapped) is uncertain with \(interaction.sub2.nameUnwrapped)")
                            .foregroundColor(InteractionType.uncertain.color)
                    }
                }
            }
            if preset.hasDangerousInteractionsToShow {
                Section("Dangerous Interactions (Not Exhaustive)") {
                    ForEach(preset.dangerousPsychoactives) { psych in
                        NavigationLink {
                            PsychoactiveView(psychoactive: psych)
                        } label: {
                            InteractionLabel(text: psych.nameUnwrapped, interactionType: .dangerous)
                        }
                    }
                    ForEach(preset.dangerousChemicals) { chem in
                        NavigationLink {
                            ChemicalView(chemical: chem)
                        } label: {
                            InteractionLabel(text: chem.nameUnwrapped, interactionType: .dangerous)
                        }
                    }
                    ForEach(preset.dangerousSubstances) { sub in
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            InteractionLabel(text: sub.nameUnwrapped, interactionType: .dangerous)
                        }
                    }
                    ForEach(preset.dangerousUnresolveds) { unr in
                        NavigationLink {
                            UnresolvedView(unresolved: unr)
                        } label: {
                            InteractionLabel(text: unr.nameUnwrapped, interactionType: .dangerous)
                        }
                    }
                }
            }
            if preset.hasUnsafeInteractionsToShow {
                Section("Unsafe Interactions (Not Exhaustive)") {
                    ForEach(preset.unsafePsychoactives) { psych in
                        NavigationLink {
                            PsychoactiveView(psychoactive: psych)
                        } label: {
                            InteractionLabel(text: psych.nameUnwrapped, interactionType: .unsafe)
                        }
                    }
                    ForEach(preset.unsafeChemicals) { chem in
                        NavigationLink {
                            ChemicalView(chemical: chem)
                        } label: {
                            InteractionLabel(text: chem.nameUnwrapped, interactionType: .unsafe)
                        }
                    }
                    ForEach(preset.unsafeSubstances) { sub in
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            InteractionLabel(text: sub.nameUnwrapped, interactionType: .unsafe)
                        }
                    }
                    ForEach(preset.unsafeUnresolveds) { unr in
                        NavigationLink {
                            UnresolvedView(unresolved: unr)
                        } label: {
                            InteractionLabel(text: unr.nameUnwrapped, interactionType: .unsafe)
                        }
                    }
                }
            }
            if preset.hasUncertainInteractionsToShow {
                Section("Uncertain Interactions (Not Exhaustive)") {
                    ForEach(preset.uncertainPsychoactives) { psych in
                        NavigationLink {
                            PsychoactiveView(psychoactive: psych)
                        } label: {
                            InteractionLabel(text: psych.nameUnwrapped, interactionType: .uncertain)
                        }
                    }
                    ForEach(preset.uncertainChemicals) { chem in
                        NavigationLink {
                            ChemicalView(chemical: chem)
                        } label: {
                            InteractionLabel(text: chem.nameUnwrapped, interactionType: .uncertain)
                        }
                    }
                    ForEach(preset.uncertainSubstances) { sub in
                        NavigationLink {
                            SubstanceView(substance: sub)
                        } label: {
                            InteractionLabel(text: sub.nameUnwrapped, interactionType: .uncertain)
                        }
                    }
                    ForEach(preset.uncertainUnresolveds) { unr in
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
}

struct PresetInteractionsSection_Previews: PreviewProvider {
    static var previews: some View {
        PresetInteractionsSection(preset: PreviewHelper.shared.preset)
    }
}
