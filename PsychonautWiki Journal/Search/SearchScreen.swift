import SwiftUI

struct SearchScreen: View {

    @StateObject var viewModel = SearchViewModel()

    var body: some View {
        List {
            ForEach(viewModel.filteredSubstances) { sub in
                SearchSubstanceRow(substance: sub, color: nil)
            }
            ForEach(viewModel.filteredCustomSubstances) { cust in
                NavigationLink {
                    EditCustomSubstanceView(customSubstance: cust)
                } label: {
                    VStack(alignment: .leading) {
                        Text(cust.nameUnwrapped).font(.headline)
                        Spacer().frame(height: 5)
                        Chip(name: "custom")
                    }
                }
            }
            if viewModel.filteredSubstances.isEmpty && viewModel.filteredCustomSubstances.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
            Button {
                viewModel.isShowingAddCustomSubstance.toggle()
            } label: {
                Label("New Custom Substance", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
            }
            .sheet(isPresented: $viewModel.isShowingAddCustomSubstance) {
                AddCustomSubstanceView()
            }
        }
        .searchable(
            text: $viewModel.searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("Search Substance")
        )
        .disableAutocorrection(true)
        .navigationTitle("Substances")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu(content: {
                    ForEach(viewModel.allCategories, id: \.self) { cat in
                        Button {
                            viewModel.toggleCategory(category: cat)
                        } label: {
                            if viewModel.selectedCategories.contains(cat) {
                                Label(cat, systemImage: "checkmark")
                            } else {
                                Text(cat)
                            }
                        }
                    }
                }, label: {
                    Label("Filter", systemImage: viewModel.selectedCategories.isEmpty ? "line.3.horizontal.decrease.circle": "line.3.horizontal.decrease.circle.fill")
                })
                if !viewModel.selectedCategories.isEmpty {
                    Button {
                        viewModel.clearCategories()
                    } label: {
                        Text("Clear")
                    }

                }
            }
        }
    }
}
