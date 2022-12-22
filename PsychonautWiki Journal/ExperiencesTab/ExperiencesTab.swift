import SwiftUI

struct ExperiencesTab: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ExperiencesList(viewModel: viewModel)
                    .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
                    .disableAutocorrection(true)
                if viewModel.experiences.isEmpty {
                    Button(action: {
                        viewModel.isShowingAddIngestionSheet.toggle()
                    }, label: {
                        Label("Add Ingestion", systemImage: "plus")
                    })
                    .buttonStyle(.primary)
                    .padding()
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddIngestionSheet) {
                ChooseSubstanceScreen()
            }
            .navigationTitle("Experiences")
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        viewModel.isTimeRelative.toggle()
                    } label: {
                        Label("Relative Time", systemImage: "timer.circle" + (viewModel.isTimeRelative ? ".fill" : ""))
                    }
                    if !viewModel.experiences.isEmpty {
                        Button {
                            viewModel.isShowingAddIngestionSheet.toggle()
                        } label: {
                            Label("Add Ingestion", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
}
