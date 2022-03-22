import SwiftUI

struct EffectView: View {

    let effect: Effect
    @EnvironmentObject var sheetViewModel: SheetViewModel

    var body: some View {
        List {
            if let articleURL = effect.url {
                Button {
                    sheetViewModel.sheetToShow = .article(url: articleURL)
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
    }
}

struct EffectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EffectView(effect: PreviewHelper.shared.substance.effectsUnwrapped.first!)
        }
    }
}
