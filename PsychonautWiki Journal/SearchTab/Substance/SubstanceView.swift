import SwiftUI

struct SubstanceView: View {

    let substance: Substance

    var body: some View {
        NavigationView {
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

                let hasSubs = !substance.crossToleranceSubstancesUnwrapped.isEmpty
                let hasPsych = !substance.crossTolerancePsychoactivesUnwrapped.isEmpty
                let hasChem = !substance.crossToleranceChemicalsUnwrapped.isEmpty
                let showTolerance = hasSubs || hasPsych || hasChem
                if showTolerance {
                    Section("Cross Tolerance") {
                        ForEach(substance.crossTolerancePsychoactivesUnwrapped) { psych in
                            Text(psych.nameUnwrapped)
                        }
                        ForEach(substance.crossToleranceChemicalsUnwrapped) { chem in
                            Text(chem.nameUnwrapped)
                        }
                        ForEach(substance.crossToleranceSubstancesUnwrapped) { subs in
                            Text(subs.nameUnwrapped)
                        }
                    }
                }

                ForEach(substance.roasUnwrapped) { roa in
                    Section(roa.nameUnwrapped.rawValue) {
                        DoseView(roaDose: roa.dose)
                        DurationView(duration: roa.duration)
                        if let bio = roa.bioavailability?.displayString {
                            RowLabelView(label: "Bioavailability", value: "\(bio)%")
                        }
                    }
                }

                Section("Interactions (Not Exhaustive)") {
                    Group {
                        ForEach(substance.uncertainPsychoactivesUnwrapped) { psych in
                            Text(psych.nameUnwrapped)
                                .listRowBackground(Color.yellow)
                        }
                        ForEach(substance.uncertainChemicalsUnwrapped) { chem in
                            Text(chem.nameUnwrapped)
                                .listRowBackground(Color.yellow)
                        }
                        ForEach(substance.uncertainSubstancesUnwrapped) { subs in
                            Text(subs.nameUnwrapped)
                                .listRowBackground(Color.yellow)
                        }
                        ForEach(substance.uncertainUnresolvedUnwrapped) { unr in
                            Text(unr.nameUnwrapped)
                                .listRowBackground(Color.yellow)
                        }
                    }
                    Group {
                        ForEach(substance.unsafePsychoactivesUnwrapped) { psych in
                            Text(psych.nameUnwrapped)
                            .listRowBackground(Color.orange)                        }
                        ForEach(substance.unsafeChemicalsUnwrapped) { chem in
                            Text(chem.nameUnwrapped)
                                .listRowBackground(Color.orange)
                        }
                        ForEach(substance.unsafeSubstancesUnwrapped) { subs in
                            Text(subs.nameUnwrapped)
                                .listRowBackground(Color.orange)
                        }
                        ForEach(substance.unsafeUnresolvedUnwrapped) { unr in
                            Text(unr.nameUnwrapped)
                                .listRowBackground(Color.orange)
                        }
                    }
                    Group {
                        ForEach(substance.dangerousPsychoactivesUnwrapped) { psych in
                            Text(psych.nameUnwrapped)
                                .listRowBackground(Color.red)
                        }
                        ForEach(substance.dangerousChemicalsUnwrapped) { chem in
                            Text(chem.nameUnwrapped)
                                .listRowBackground(Color.red)
                        }
                        ForEach(substance.dangerousSubstancesUnwrapped) { subs in
                            Text(subs.nameUnwrapped)
                                .listRowBackground(Color.red)
                        }
                        ForEach(substance.dangerousUnresolvedUnwrapped) { unr in
                            Text(unr.nameUnwrapped)
                                .listRowBackground(Color.red)
                        }
                    }
                }
            }
            .navigationTitle(substance.nameUnwrapped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let url = substance.url {
                        Link("Article", destination: url)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ingest", action: ingest)
                }
            }
        }
    }

    private func ingest() {

    }
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
        SubstanceView(substance: PreviewHelper().getSubstance(with: "Caffeine")!)
    }
}
