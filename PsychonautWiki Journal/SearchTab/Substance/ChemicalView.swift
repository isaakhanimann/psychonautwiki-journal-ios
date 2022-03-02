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
                SubstanceInteractionsSection(substanceInteractable: chemical)
            }
            if !chemical.crossToleranceUnwrapped.isEmpty {
                Section("Cross Tolerance (not exhaustive)") {
                    ForEach(chemical.crossToleranceUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }
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
