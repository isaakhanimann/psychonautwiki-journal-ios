import SwiftUI

struct EffectView: View {

    let effect: Effect

    var body: some View {
        List {
            ArticleURLLink(articleURL: effect.url)
            Section("Substances with this effect") {
                ForEach(effect.substancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                }
            }
        }
        .navigationTitle(effect.nameUnwrapped)
    }
}

struct EffectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EffectView(effect: PreviewHelper.shared.substance.effectsUnwrapped.first!)
        }
    }
}
