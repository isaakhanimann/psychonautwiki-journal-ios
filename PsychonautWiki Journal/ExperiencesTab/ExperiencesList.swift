import SwiftUI

struct ExperiencesList: View {

    @ObservedObject var viewModel: ExperiencesTab.ViewModel
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.experiences) { exp in
                    ExperienceRow(experience: exp)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel.delete(experience: viewModel.experiences[index])
                    }
                }
            }
            if isSearching && viewModel.experiences.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}
