import SwiftUI

struct SearchTab: View {

    @StateObject var sectionedViewModel = SectionedSubstancesViewModel()

    var body: some View {
        NavigationView {
            SearchList(sectionedViewModel: sectionedViewModel)
            .navigationTitle("Substances")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Picker("Group By", selection: $sectionedViewModel.groupBy) {
                            Text("Psychoactive Class").tag(GroupBy.psychoactive)
                            Text("Chemical Class").tag(GroupBy.chemical)
                        }
                    } label: {
                        Label("More", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
            }
        }
        .searchable(
            text: $sectionedViewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search by substance or class")
        )
        .disableAutocorrection(true)
    }
}

struct SearchTab_Previews: PreviewProvider {
    static var previews: some View {
        SearchTab(
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true)
        )
    }
}
