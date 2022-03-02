import SwiftUI

struct UnresolvedView: View {

    let unresolved: UnresolvedInteraction

    var body: some View {
        List {
            SubstanceInteractionsSection(substanceInteractable: unresolved)
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
