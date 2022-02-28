import SwiftUI

struct SearchTab: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                Text("hello: \(viewModel.sortedSubstances.count)")
                ForEach(viewModel.sortedSubstances) { substance in
                    Text(substance.nameUnwrapped)
                }
            }
            .navigationTitle("Substances")
        }
        .searchable(text: $viewModel.searchText)
    }
}

struct SearchTab_Previews: PreviewProvider {
    static var previews: some View {
        SearchTab(viewModel: SearchTab.ViewModel(isPreview: true))
    }
}
