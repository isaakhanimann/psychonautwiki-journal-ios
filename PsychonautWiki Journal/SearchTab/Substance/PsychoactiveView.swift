import SwiftUI

struct PsychoactiveView: View {

    let psychoactive: PsychoactiveClass

    var body: some View {
        List {
            Section("Substances in this psychoactive class") {
                ForEach(psychoactive.substancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                }
            }
            let hasUncertain = !psychoactive.uncertainSubstancesToShow.isEmpty
            let hasUnsafe = !psychoactive.unsafeSubstancesToShow.isEmpty
            let hasDangerous = !psychoactive.dangerousSubstancesToShow.isEmpty
            let showInteractions = hasUncertain || hasUnsafe || hasDangerous
            if showInteractions {
                SubstanceInteractionsSection(substanceInteractable: psychoactive)
            }
            if !psychoactive.crossToleranceUnwrapped.isEmpty {
                Section("Cross Tolerance (not exhaustive)") {
                    ForEach(psychoactive.crossToleranceUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }
                    }
                }
            }
        }
        .navigationTitle(psychoactive.nameUnwrapped)
        .toolbar {
            ArticleToolbarItem(articleURL: psychoactive.url)
        }
    }
}

struct PsychoactiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PsychoactiveView(psychoactive: PreviewHelper.shared.substancesFile.psychoactiveClassesUnwrapped.first!)
        }
    }
}
