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
                SubstanceRow(substance: sub, dismiss: dismiss, experience: experience)
            }
            .navigationBarTitle("Add Ingestion")
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
            .environmentObject(PreviewHelper.shared.experiences.first!)
    }
}
