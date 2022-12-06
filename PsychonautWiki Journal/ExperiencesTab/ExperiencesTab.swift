import SwiftUI

struct ExperiencesTab: View {

    @StateObject var viewModel = ViewModel()
    @State private var isShowingAddIngestionSheet = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ExperiencesList(viewModel: viewModel)
                    .searchable(text: $viewModel.searchText, prompt: "Search by title or substance")
                    .disableAutocorrection(true)
                if viewModel.experiences.isEmpty {
                    Button(action: {
                        isShowingAddIngestionSheet.toggle()
                    }, label: {
                        Label("Add Ingestion", systemImage: "plus")
                    })
                    .buttonStyle(.primary)
                    .padding()
                }
            }
            .sheet(isPresented: $isShowingAddIngestionSheet) {
                ChooseSubstanceView()
            }
            .navigationTitle("Experiences")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.experiences.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.experiences.isEmpty {
                        Button {
                            isShowingAddIngestionSheet.toggle()
                        } label: {
                            Label("Add Ingestion", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
}
