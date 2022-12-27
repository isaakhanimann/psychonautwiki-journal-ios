import SwiftUI

struct HomeScreen: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ExperiencesList(viewModel: viewModel)
                .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
                .disableAutocorrection(true)
        }
        .navigationTitle("Journal")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isTimeRelative.toggle()
                } label: {
                    Label("Relative Time", systemImage: "timer.circle" + (viewModel.isTimeRelative ? ".fill" : ""))
                }
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
            }

        }
    }
}