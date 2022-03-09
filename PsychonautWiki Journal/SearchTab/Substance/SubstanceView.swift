import SwiftUI
import AlertToast

struct SubstanceView: View {

    let substance: Substance
    @State private var isShowingAddIngestionSheet = false
    @State private var isShowingSuccessToast = false

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
                InteractionsSection(substance: substance)
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
        .sheet(isPresented: $isShowingAddIngestionSheet) {
            NavigationView {
                if substance.hasAnyInteractions {
                    AcknowledgeInteractionsView(
                        substance: substance,
                        dismiss: dismiss,
                        experience: nil
                    )
                } else {
                    ChooseRouteView(
                        substance: substance,
                        dismiss: dismiss,
                        experience: nil
                    )
                }
            }
            .accentColor(Color.blue)
        }
        .toast(isPresenting: $isShowingSuccessToast) {
            AlertToast(
                displayMode: .alert,
                type: .complete(Color.green),
                title: "Ingestion Added"
            )
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

    private func dismiss(result: AddResult) {
        if result == .ingestionWasAdded {
            isShowingSuccessToast.toggle()
        }
        isShowingAddIngestionSheet.toggle()
    }

    private func ingest() {
        isShowingAddIngestionSheet.toggle()
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
        NavigationView {
            SubstanceView(substance: PreviewHelper.shared.getSubstance(with: "Tyrosine")!)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
        }
    }
}
