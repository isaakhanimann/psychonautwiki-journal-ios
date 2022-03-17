import SwiftUI

struct ChooseSubstanceView: View {

    @StateObject var sectionedViewModel = SectionedSubstancesViewModel()
    @EnvironmentObject var sheetContext: AddIngestionSheetContext

    var body: some View {
        NavigationView {
            ChooseSubstanceList(sectionedViewModel: sectionedViewModel)
            .navigationBarTitle("Add Ingestion")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        sheetContext.isShowingAddIngestionSheet.toggle()
                    }
                }
            }
        }
        .searchable(text: $sectionedViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceView()
    }
}
