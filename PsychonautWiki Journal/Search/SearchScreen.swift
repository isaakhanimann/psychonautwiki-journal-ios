import SwiftUI

struct SearchScreen: View {

    @StateObject var viewModel = SearchViewModel()
    @State private var isShowingAddCustomSubstance = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            SearchList(searchViewModel: viewModel)
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("Search Substance")
                )
                .disableAutocorrection(true)
                .navigationTitle("Substances")
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            isShowingAddCustomSubstance.toggle()
                        } label: {
                            Label("Add Custom", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                        }
                    }
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
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $isShowingAddCustomSubstance) {
                    AddCustomSubstanceView()
                }
        }
    }
}
