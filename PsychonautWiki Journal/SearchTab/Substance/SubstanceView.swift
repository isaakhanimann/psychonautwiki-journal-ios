import SwiftUI

struct SubstanceView: View {

    let substance: Substance
    var areThereInteractions: Bool {
        guard substance.uncertainSubstancesUnwrapped.isEmpty else {return true}
        guard substance.uncertainPsychoactivesUnwrapped.isEmpty else {return true}
        guard substance.uncertainChemicalsUnwrapped.isEmpty else {return true}
        guard substance.uncertainUnresolvedsUnwrapped.isEmpty else {return true}
        guard substance.unsafeSubstancesUnwrapped.isEmpty else {return true}
        guard substance.unsafePsychoactivesUnwrapped.isEmpty else {return true}
        guard substance.unsafeChemicalsUnwrapped.isEmpty else {return true}
        guard substance.unsafeUnresolvedsUnwrapped.isEmpty else {return true}
        guard substance.dangerousSubstancesUnwrapped.isEmpty else {return true}
        guard substance.dangerousPsychoactivesUnwrapped.isEmpty else {return true}
        guard substance.dangerousChemicalsUnwrapped.isEmpty else {return true}
        guard substance.dangerousUnresolvedsUnwrapped.isEmpty else {return true}
        return false
    }

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
            if substance.tolerance?.isAtLeastOneDefined ?? false {
                toleranceSection
            }
            let hasSubs = !substance.crossToleranceSubstancesUnwrapped.isEmpty
            let hasPsych = !substance.crossTolerancePsychoactivesUnwrapped.isEmpty
            let hasChem = !substance.crossToleranceChemicalsUnwrapped.isEmpty
            let showTolerance = hasSubs || hasPsych || hasChem
            if showTolerance {
                crossToleranceSection
            }
            roaSection
            if areThereInteractions {
                interactionSection
            }
            if !substance.psychoactivesUnwrapped.isEmpty {
                psychoactiveSection
            }
            if !substance.chemicalsUnwrapped.isEmpty {
                chemicalSection
            }
            if !substance.effectsUnwrapped.isEmpty {
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
                ForEach(substance.dangerousPsychoactivesUnwrapped) { psych in
                    NavigationLink {
                        PsychoactiveView(psychoactive: psych)
                    } label: {
                        InteractionLabel(text: psych.nameUnwrapped, interactionType: .dangerous)
                    }
                }
                ForEach(substance.dangerousChemicalsUnwrapped) { chem in
                    NavigationLink {
                        ChemicalView(chemical: chem)
                    } label: {
                        InteractionLabel(text: chem.nameUnwrapped, interactionType: .dangerous)
                    }
                }
                ForEach(substance.dangerousSubstancesUnwrapped) { sub in
                    NavigationLink {
                        SubstanceView(substance: sub)
                    } label: {
                        InteractionLabel(text: sub.nameUnwrapped, interactionType: .dangerous)
                    }
                }
                ForEach(substance.dangerousUnresolvedsUnwrapped) { unr in
                    NavigationLink {
                        UnresolvedView(unresolved: unr)
                    } label: {
                        InteractionLabel(text: unr.nameUnwrapped, interactionType: .dangerous)
                    }
                }
            }
            Group {
                ForEach(substance.unsafePsychoactivesUnwrapped) { psych in
                    NavigationLink {
                        PsychoactiveView(psychoactive: psych)
                    } label: {
                        InteractionLabel(text: psych.nameUnwrapped, interactionType: .unsafe)
                    }
                }
                ForEach(substance.unsafeChemicalsUnwrapped) { chem in
                    NavigationLink {
                        ChemicalView(chemical: chem)
                    } label: {
                        InteractionLabel(text: chem.nameUnwrapped, interactionType: .unsafe)
                    }
                }
                ForEach(substance.unsafeSubstancesUnwrapped) { sub in
                    NavigationLink {
                        SubstanceView(substance: sub)
                    } label: {
                        InteractionLabel(text: sub.nameUnwrapped, interactionType: .unsafe)
                    }
                }
                ForEach(substance.unsafeUnresolvedsUnwrapped) { unr in
                    NavigationLink {
                        UnresolvedView(unresolved: unr)
                    } label: {
                        InteractionLabel(text: unr.nameUnwrapped, interactionType: .unsafe)
                    }
                }
            }
            Group {
                ForEach(substance.uncertainPsychoactivesUnwrapped) { psych in
                    NavigationLink {
                        PsychoactiveView(psychoactive: psych)
                    } label: {
                        InteractionLabel(text: psych.nameUnwrapped, interactionType: .uncertain)
                    }
                }
                ForEach(substance.uncertainChemicalsUnwrapped) { chem in
                    NavigationLink {
                        ChemicalView(chemical: chem)
                    } label: {
                        InteractionLabel(text: chem.nameUnwrapped, interactionType: .uncertain)
                    }
                }
                ForEach(substance.uncertainSubstancesUnwrapped) { sub in
                    NavigationLink {
                        SubstanceView(substance: sub)
                    } label: {
                        InteractionLabel(text: sub.nameUnwrapped, interactionType: .uncertain)
                    }
                }
                ForEach(substance.uncertainUnresolvedsUnwrapped) { unr in
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
        Section("Psychoactive Classes") {
            ForEach(substance.psychoactivesUnwrapped) { psy in
                NavigationLink(psy.nameUnwrapped) {
                    PsychoactiveView(psychoactive: psy)
                }
            }
        }
    }

    private var chemicalSection: some View {
        Section("Chemical Classes") {
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
            SubstanceView(substance: PreviewHelper.shared.getSubstance(with: "Caffeine")!)
        }
    }
}
