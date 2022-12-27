import SwiftUI

struct HomeScreen: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ExperiencesList(viewModel: viewModel)
                    .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
                    .disableAutocorrection(true)
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        SettingsScreen()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
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
                        viewModel.isShowingSafer.toggle()
                    } label: {
                        Text("Safer")
                    }
                    .fullScreenCover(isPresented: $viewModel.isShowingSafer) {
                        SaferScreen()
                    }
                    Button {
                        viewModel.isShowingSubstances.toggle()
                    } label: {
                        Text("Substances")
                    }.fullScreenCover(isPresented: $viewModel.isShowingSubstances) {
                        SearchScreen()
                    }
                    Button {
                        viewModel.isShowingAddIngestionSheet.toggle()
                    } label: {
                        Label("Add Ingestion", systemImage: "plus.circle.fill").labelStyle(.titleAndIcon).font(.headline)
                    }.fullScreenCover(isPresented: $viewModel.isShowingAddIngestionSheet) {
                        ChooseSubstanceScreen()
                    }
                }

            }
        }
    }
}
