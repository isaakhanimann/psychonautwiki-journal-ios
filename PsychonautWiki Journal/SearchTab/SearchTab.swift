import SwiftUI

struct SearchTab: View {

    @StateObject var searchViewModel = SearchViewModel()

    var body: some View {
        NavigationView {
            SearchList(searchViewModel: searchViewModel)
                .searchable(
                    text: $searchViewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Search Substance")
                )
                .disableAutocorrection(true)
                .navigationTitle("Substances")
        }
    }
}
