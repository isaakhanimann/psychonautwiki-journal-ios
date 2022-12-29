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
                NavigationLink {
                    StatsScreen()
                } label: {
                    Label("Stats", systemImage: "chart.bar")
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
                Button {
                    viewModel.isTimeRelative.toggle()
                } label: {
                    Label("Relative Time", systemImage: "timer.circle" + (viewModel.isTimeRelative ? ".fill" : ""))
                }
                Button {
                    viewModel.isFavoriteFilterEnabled.toggle()
                } label: {
                    Label("Filter Favorites", systemImage: viewModel.isFavoriteFilterEnabled ? "star.fill" : "star")
                }
            }

        }
    }
}
