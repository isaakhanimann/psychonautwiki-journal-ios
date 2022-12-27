import SwiftUI

struct ExperiencesList: View {

    @ObservedObject var viewModel: JournalScreen.ViewModel
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.experiences) { exp in
                    ExperienceRow(experience: exp, isTimeRelative: viewModel.isTimeRelative)
                }
            }
            if isSearching && viewModel.experiences.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}
