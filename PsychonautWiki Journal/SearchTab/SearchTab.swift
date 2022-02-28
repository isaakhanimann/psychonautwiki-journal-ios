import SwiftUI

struct SearchTab: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sortedSubstances) { substance in
                    Text(substance.nameUnwrapped)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Substances")
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

struct SearchTab_Previews: PreviewProvider {
    static var previews: some View {
        SearchTab(viewModel: SearchTab.ViewModel(isPreview: true))
    }
}
