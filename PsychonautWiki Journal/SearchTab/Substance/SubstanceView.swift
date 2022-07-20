import SwiftUI

struct SubstanceView: View {

    let substance: Substance
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @EnvironmentObject private var sheetViewModel: SheetViewModel

    var body: some View {
        List {
            if isEyeOpen {
                if let articleURL = substance.url {
                    Button {
                        sheetViewModel.sheetToShow = .article(url: articleURL)
                    } label: {
                        Label("Article", systemImage: "link")
                    }
                }
            }
            if let addictionPotential = substance.addictionPotential {
                Section("Addiction Potential") {
                    Text(addictionPotential)
                }
            }
            if let toxicities = substance.toxicities, !toxicities.isEmpty {
                Section("Toxicity") {
                    VStack {
                        ForEach(toxicities, id: \.self) { toxicity in
                            Text(toxicity)
                        }
                    }
                }
            }
            if substance.tolerance != nil {
                toleranceSection
            }
            roaSection
            if !substance.crossTolerances.isEmpty && isEyeOpen {
                crossToleranceSection
            }
            if isEyeOpen {
                InteractionsSection(substance: substance)
                if !substance.psychoactiveClasses.isEmpty {
                    psychoactiveSection
                }
                if !substance.chemicalClasses.isEmpty {
                    chemicalSection
                }
            }
        }
        .navigationTitle(substance.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("", action: {}) // here so that SwiftUI layout works
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Ingest") {
                    sheetViewModel.sheetToShow = .addIngestionFromSubstance(substance: substance)
                }
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
        }
    }

    private var roaSection: some View {
        ForEach(substance.roas, id: \.name) { roa in
            Section(roa.name.rawValue) {
                DoseView(roaDose: roa.dose)
                DurationView(duration: roa.duration)
                if let bio = roa.bioavailability?.displayString {
                    RowLabelView(label: "Bioavailability", value: "\(bio)%")
                }
            }
            .listRowSeparator(.hidden)
        }
    }

    private var psychoactiveSection: some View {
        Section("Psychoactive Class") {
            ForEach(substance.psychoactiveClasses, id: \.self) { psy in
                Text(psy)
            }
        }
    }

    private var chemicalSection: some View {
        Section("Chemical Class") {
            ForEach(substance.chemicalClasses, id: \.self) { che in
                Text(che)
            }
        }
    }
}
