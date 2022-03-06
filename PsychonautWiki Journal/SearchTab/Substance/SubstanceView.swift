import SwiftUI

struct SubstanceView: View {

    let substance: Substance

    var body: some View {
        List {
            if let addictionPotential = substance.addictionPotentialUnwrapped {
                Section("Addiction Potential") {
                    Text(addictionPotential)
                }
            }
            if let toxicity = substance.toxicityUnwrapped {
                Section("Toxicity") {
                    Text(toxicity)
                }
            }
            if substance.showTolerance {
                toleranceSection
            }
            roaSection
            if substance.showCrossTolerance {
                crossToleranceSection
            }
            if substance.areThereInteractions {
                interactionSection
            }
            if substance.showPsychoactiveClass {
                psychoactiveSection
            }
            if substance.showChemicalClass {
                chemicalSection
            }
            if substance.showEffects {
                effectSection
            }
        }
        .navigationTitle(substance.nameUnwrapped)
        .toolbar {
            ArticleToolbarItem(articleURL: substance.url)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Ingest", action: ingest)
            }
        }
    }

    private var toleranceSection: some View {
        Section("Tolerance") {
            if let zero = substance.tolerance?.zero {
                RowLabelView(label: "zero", value: zero)
            }
            if let half = substance.tolerance?.half {
                RowLabelView(label: "half", value: half)
            }
            if let full = substance.tolerance?.full {
                RowLabelView(label: "full", value: full)
            }
        }
    }

    private var crossToleranceSection: some View {
        Section("Cross Tolerance (not exhaustive)") {
            ForEach(substance.crossTolerancePsychoactivesUnwrapped) { psych in
                NavigationLink(psych.nameUnwrapped) {
                    PsychoactiveView(psychoactive: psych)
                }
            }
            ForEach(substance.crossToleranceChemicalsUnwrapped) { chem in
                NavigationLink(chem.nameUnwrapped) {
                    ChemicalView(chemical: chem)
                }
            }
            ForEach(substance.crossToleranceSubstancesUnwrapped) { sub in
                NavigationLink(sub.nameUnwrapped) {
                    SubstanceView(substance: sub)
                }
            }
        }
    }

    private var roaSection: some View {
        ForEach(substance.roasUnwrapped) { roa in
            Section(roa.nameUnwrapped.rawValue) {
                DoseView(roaDose: roa.dose)
                DurationView(duration: roa.duration)
                if let bio = roa.bioavailability?.displayString {
                    RowLabelView(label: "Bioavailability", value: "\(bio)%")
                }
            }
        }
    }

    private var interactionSection: some View {
        return Section("Interactions (Not Exhaustive)") {
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

    private var effectSection: some View {
        Section("Subjective Effects (not exhaustive)") {
            ForEach(substance.effectsUnwrapped) { eff in
                NavigationLink(eff.nameUnwrapped) {
                    EffectView(effect: eff)
                }
            }
        }
    }

    private var psychoactiveSection: some View {
        Section("Psychoactive Class") {
            ForEach(substance.psychoactivesUnwrapped) { psy in
                NavigationLink(psy.nameUnwrapped) {
                    PsychoactiveView(psychoactive: psy)
                }
            }
        }
    }

    private var chemicalSection: some View {
        Section("Chemical Class") {
            ForEach(substance.chemicalsUnwrapped) { che in
                NavigationLink(che.nameUnwrapped) {
                    ChemicalView(chemical: che)
                }
            }
        }
    }

    private func ingest() {}
}

struct RowLabelView: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label+" ")
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct SubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubstanceView(substance: PreviewHelper.shared.getSubstance(with: "Tyrosine")!)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
        }
    }
}
