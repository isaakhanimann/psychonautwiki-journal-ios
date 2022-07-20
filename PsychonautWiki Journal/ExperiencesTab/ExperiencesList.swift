import SwiftUI

struct ExperiencesList: View {

    @ObservedObject var viewModel: ExperiencesTab.ViewModel
    @Environment(\.editMode) private var mode
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.sections) { sec in
                    Section(String(sec.year)) {
                        ForEach(sec.experiences) { exp in
                            let isEditing = mode?.wrappedValue.isEditing ?? false
                            ExperienceRow(experience: exp, selection: $viewModel.selection)
                                .deleteDisabled(!isEditing)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                viewModel.delete(experience: sec.experiences[index])
                            }
                            if viewModel.sections.isEmpty {
                                mode?.wrappedValue = .inactive
                            }
                        }
                    }
                }
            }
            if isSearching && viewModel.sections.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}
