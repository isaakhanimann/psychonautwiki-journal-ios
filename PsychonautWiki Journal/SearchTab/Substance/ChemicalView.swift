import SwiftUI

struct ChemicalView: View {

    let chemical: ChemicalClass

    var body: some View {
        List {
            Section("Substances in this chemical class") {
                ForEach(chemical.substancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                }
            }
            let hasUncertain = !chemical.uncertainSubstancesUnwrapped.isEmpty
            let hasUnsafe = !chemical.unsafeSubstancesUnwrapped.isEmpty
            let hasDangerous = !chemical.dangerousSubstancesUnwrapped.isEmpty
            let showInteractions = hasUncertain || hasUnsafe || hasDangerous
            if showInteractions {
                Section("Interactions (not exhaustive)") {
                    ForEach(chemical.uncertainSubstancesUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.yellow)
                    }
                    ForEach(chemical.unsafeSubstancesUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.orange)
                    }
                    ForEach(chemical.dangerousSubstancesUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.red)
                    }
                }
            }
            if !chemical.crossToleranceUnwrapped.isEmpty {
                Section("Cross tolerance (not exhaustive)") {
                    ForEach(chemical.crossToleranceUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.yellow)
                    }
                }
            }
        }
        .navigationTitle(chemical.nameUnwrapped)
        .toolbar {
            ArticleToolbarItem(articleURL: chemical.url)
        }
    }
}

struct ChemicalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChemicalView(chemical: PreviewHelper.shared.substancesFile.chemicalClassesUnwrapped.first!)
        }
    }
}
