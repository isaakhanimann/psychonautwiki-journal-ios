import SwiftUI

struct ExperiencesList: View {

    @ObservedObject var viewModel: JournalScreen.ViewModel
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                if !viewModel.currentExperiences.isEmpty {
                    Section("Current") {
                        ForEach(viewModel.currentExperiences) { exp in
                            ExperienceRow(experience: exp, isTimeRelative: viewModel.isTimeRelative)
                        }

                    }
                    if !viewModel.previousExperiences.isEmpty {
                        Section("Previous") {
                            ForEach(viewModel.previousExperiences) { exp in
                                ExperienceRow(experience: exp, isTimeRelative: viewModel.isTimeRelative)
                            }
                        }
                    }
                } else {
                    ForEach(viewModel.previousExperiences) { exp in
                        ExperienceRow(experience: exp, isTimeRelative: viewModel.isTimeRelative)
                    }
                }
            }
            if viewModel.currentExperiences.isEmpty && viewModel.previousExperiences.isEmpty {
                if isSearching {
                    Text("No Results")
                        .foregroundColor(.secondary)
                } else if viewModel.isFavoriteFilterEnabled {
                    Text("No Favorites")
                        .foregroundColor(.secondary)
                } else {
                    Text("No Ingestions Yet")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
