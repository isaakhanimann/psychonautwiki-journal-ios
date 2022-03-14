import SwiftUI

struct ExperiencesTab: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ExperiencesList(viewModel: viewModel)
                if !viewModel.hasExperiences {
                    Button(action: {
                        withAnimation {
                            viewModel.addExperience()
                        }
                    }, label: {
                        Label("Add Experience", systemImage: "plus")

                    })
                        .buttonStyle(.primary)
                        .padding()
                }
            }
            .navigationTitle("Experiences")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.hasExperiences {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.hasExperiences {
                        Button {
                            withAnimation {
                                viewModel.addExperience()
                            }
                        } label: {
                            Label("Add Experience", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .disableAutocorrection(true)
    }
}

struct YourExperiencesTab_Previews: PreviewProvider {
    static var previews: some View {
        ExperiencesTab(viewModel: ExperiencesTab.ViewModel(isPreview: true))
    }
}
