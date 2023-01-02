import SwiftUI

struct JournalScreen: View {

    @StateObject var viewModel = ViewModel()
    @Binding var isShowingCurrentExperience: Bool

    var body: some View {
        ExperiencesList(viewModel: viewModel, isShowingCurrentExperience: $isShowingCurrentExperience)
            .optionalScrollDismissesKeyboard()
            .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
            .disableAutocorrection(true)
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.isTimeRelative.toggle()
                        } label: {
                            if viewModel.isTimeRelative {
                                Label("Show Absolute Time", systemImage: "timer.circle.fill")
                            } else {
                                Label("Show Relative Time", systemImage: "timer.circle")
                            }
                        }
                        Button {
                            viewModel.isFavoriteFilterEnabled.toggle()
                        } label: {
                            if viewModel.isFavoriteFilterEnabled {
                                Label("Don't Filter Favorites", systemImage: "star.fill")
                            } else {
                                Label("Filter Favorites", systemImage: "star")
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
