import SwiftUI

struct ChooseSubstanceView: View {

    @StateObject var sectionedViewModel = SectionedSubstancesViewModel()
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    let dismiss: () -> Void
    let experience: Experience

    var body: some View {
        NavigationView {
            SearchList(sectionedViewModel: sectionedViewModel,
                       recentsViewModel: recentsViewModel
            ) { sub in
                NavigationLink(sub.nameUnwrapped) {
                    if sub.hasAnyInteractions {
                        AcknowledgeInteractionsView(experience: experience, substance: sub, dismiss: dismiss)
                    } else {
                        ChooseRouteView(substance: sub, dismiss: dismiss, experience: experience)
                    }
                }
            }
            .navigationBarTitle("Add Ingestion")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel", action: dismiss)
            }
        }
        .searchable(text: $sectionedViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceView(
            dismiss: {},
            experience: PreviewHelper.shared.experiences.first!
        )
    }
}
