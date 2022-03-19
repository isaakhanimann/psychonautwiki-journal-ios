import SwiftUI

struct PsychoactiveView: View {

    let psychoactive: PsychoactiveClass
    @State private var isShowingArticle = false

    var body: some View {
        List {
            if psychoactive.url != nil {
                Button {
                    isShowingArticle.toggle()
                } label: {
                    Label("Article", systemImage: "link")
                }
            }
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
        .sheet(isPresented: $isShowingArticle) {
            if let articleURL = psychoactive.url {
                WebViewSheet(articleURL: articleURL)
            } else {
                Text("Could not find website")
            }
        }
    }
}

struct PsychoactiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PsychoactiveView(psychoactive: PreviewHelper.shared.substance.psychoactivesUnwrapped.first!)
        }
    }
}
