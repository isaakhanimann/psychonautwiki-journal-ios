import SwiftUI

struct SearchTab: View {

    @StateObject var sectionedViewModel = SectionedSubstancesViewModel()

    var body: some View {
        NavigationView {
            SearchList(sectionedViewModel: sectionedViewModel)
            .navigationTitle("Substances")
        }
        .searchable(
            text: $sectionedViewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search by substance or class")
        )
        .disableAutocorrection(true)
    }
}
