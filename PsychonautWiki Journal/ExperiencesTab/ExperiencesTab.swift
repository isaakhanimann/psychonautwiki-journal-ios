import SwiftUI

struct ExperiencesTab: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List {
                    ForEach(viewModel.sections) { sec in
                        Section(String(sec.year)) {
                            ForEach(sec.experiences) { exp in
                                ExperienceRow(experience: exp, selection: $viewModel.selection)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    viewModel.delete(experience: sec.experiences[index])
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                if !viewModel.hasExperiences {
                    Button(action: {
                        withAnimation {
                            viewModel.addExperience()
                        }
                    }, label: {
                        Label("Add Experience", systemImage: "plus")

                    })
                        .buttonStyle(PrimaryButtonStyle())
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
    }
}

struct YourExperiencesTab_Previews: PreviewProvider {
    static var previews: some View {
        ExperiencesTab()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
