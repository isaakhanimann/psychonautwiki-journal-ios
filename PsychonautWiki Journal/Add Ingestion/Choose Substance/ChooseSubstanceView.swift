import SwiftUI

struct ChooseSubstanceView: View {
    
    @StateObject var sectionedViewModel = SearchViewModel()
    @EnvironmentObject private var sheetViewModel: SheetViewModel
    
    var body: some View {
        NavigationView {
            ChooseSubstanceList(searchViewModel: sectionedViewModel)
                .searchable(text: $sectionedViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                .disableAutocorrection(true)
                .navigationBarTitle("Add Ingestion")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            sheetViewModel.dismiss()
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
