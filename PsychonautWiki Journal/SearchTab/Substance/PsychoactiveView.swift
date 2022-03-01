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
            let hasUncertain = !psychoactive.uncertainSubstancesUnwrapped.isEmpty
            let hasUnsafe = !psychoactive.unsafeSubstancesUnwrapped.isEmpty
            let hasDangerous = !psychoactive.dangerousSubstancesUnwrapped.isEmpty
            let showInteractions = hasUncertain || hasUnsafe || hasDangerous
            if showInteractions {
                Section("Interactions (not exhaustive)") {
                    ForEach(psychoactive.uncertainSubstancesUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.yellow)
                    }
                    ForEach(psychoactive.unsafeSubstancesUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.orange)
                    }
                    ForEach(psychoactive.dangerousSubstancesUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.red)
                    }
                }
            }
            if !psychoactive.crossToleranceUnwrapped.isEmpty {
                Section("Cross tolerance (not exhaustive)") {
                    ForEach(psychoactive.crossToleranceUnwrapped) { sub in
                        NavigationLink(sub.nameUnwrapped) {
                            SubstanceView(substance: sub)
                        }.listRowBackground(Color.yellow)
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
