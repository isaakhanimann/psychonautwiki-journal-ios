import SwiftUI

struct ChemicalView: View {

    let chemical: ChemicalClass
    @EnvironmentObject var sheetViewModel: SheetViewModel

    var body: some View {
        List {
            if let articleURL = chemical.url {
                Button {
                    sheetViewModel.sheetToShow = .article(url: articleURL)
                } label: {
                    Label("Article", systemImage: "link")
                }
            }
            Section("Substances in this chemical class") {
                ForEach(chemical.substancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                }
            }
            let hasUncertain = !chemical.uncertainSubstancesToShow.isEmpty
            let hasUnsafe = !chemical.unsafeSubstancesToShow.isEmpty
            let hasDangerous = !chemical.dangerousSubstancesToShow.isEmpty
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
    }
}

struct ChemicalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChemicalView(chemical: PreviewHelper.shared.substance.chemicalsUnwrapped.first!)
        }
    }
}
