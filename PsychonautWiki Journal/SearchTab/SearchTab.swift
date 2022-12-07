import SwiftUI

struct SearchTab: View {

    @StateObject var searchViewModel = SearchViewModel()
    @State private var isShowingAddCustomSubstance = false

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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingAddCustomSubstance.toggle()
                        } label: {
                            Label("Add custom substance", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isShowingAddCustomSubstance) {
                    AddCustomSubstanceView()
                }
        }
    }
}
