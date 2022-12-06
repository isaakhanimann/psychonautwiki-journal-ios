import SwiftUI

struct ChooseSubstanceView: View {

    @StateObject var searchViewModel = SearchViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ChooseSubstanceList(searchViewModel: searchViewModel, dismiss: dismiss)
                .searchable(text: $searchViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                .disableAutocorrection(true)
                .navigationBarTitle("Add Ingestion")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceView()
    }
}
