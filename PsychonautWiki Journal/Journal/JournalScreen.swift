import SwiftUI

struct JournalScreen: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ExperiencesList(viewModel: viewModel)
                .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
                .disableAutocorrection(true)
        }
        .navigationTitle("Journal")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        viewModel.isTimeRelative.toggle()
                    } label: {
                        if viewModel.isTimeRelative {
                            Label("Show Relative Time", systemImage: "checkmark")
                        } else {
                            Text("Show Relative Time")
                        }
                    }
                    Button {
                        viewModel.isFavoriteFilterEnabled.toggle()
                    } label: {
                        if viewModel.isFavoriteFilterEnabled {
                            Label("Filter Favorites", systemImage: "checkmark")
                        } else {
                            Text("Filter Favorites")
                        }
                    }
                } label: {
                    let isActive = viewModel.isTimeRelative || viewModel.isFavoriteFilterEnabled
                    Label("More", systemImage: isActive ? "ellipsis.circle.fill" : "ellipsis.circle")
                }

            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    viewModel.isShowingAddIngestionSheet.toggle()
                } label: {
                    Label("New Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                }.fullScreenCover(isPresented: $viewModel.isShowingAddIngestionSheet) {
                    ChooseSubstanceScreen()
                }
                Spacer()
                if #available(iOS 16, *) {
                    NavigationLink {
                        StatsScreen()
                    } label: {
                        Label("Stats", systemImage: "chart.bar")
                    }
                }
            }

        }
    }
}
