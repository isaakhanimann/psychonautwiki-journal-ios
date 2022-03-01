import SwiftUI

struct UnresolvedView: View {

    let unresolved: UnresolvedInteraction

    var body: some View {
        List {
            Section("Substances with this interaction") {
                ForEach(unresolved.uncertainSubstancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                    .listRowBackground(Color.yellow)
                }
                ForEach(unresolved.unsafeSubstancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                    .listRowBackground(Color.orange)
                }
                ForEach(unresolved.dangerousSubstancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                    .listRowBackground(Color.red)
                }
            }
        }
        .navigationTitle(unresolved.nameUnwrapped)
    }
}

struct UnresolvedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UnresolvedView(unresolved: PreviewHelper.shared.unresolvedInteractions.first!)
        }
    }
}
