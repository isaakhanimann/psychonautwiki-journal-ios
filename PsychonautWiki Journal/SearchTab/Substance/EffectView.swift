import SwiftUI

struct EffectView: View {

    let effect: Effect
    @State private var isShowingArticle = false

    var body: some View {
        List {
            if effect.url != nil {
                Button {
                    isShowingArticle.toggle()
                } label: {
                    Label("Article", systemImage: "link")
                }
            }
            Section("Substances with this effect") {
                ForEach(effect.substancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                }
            }
        }
        .navigationTitle(effect.nameUnwrapped)
        .sheet(isPresented: $isShowingArticle) {
            if let articleURL = effect.url {
                WebViewSheet(articleURL: articleURL)
            } else {
                Text("Could not find website")
            }
        }
    }
}

struct EffectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EffectView(effect: PreviewHelper.shared.substance.effectsUnwrapped.first!)
        }
    }
}
