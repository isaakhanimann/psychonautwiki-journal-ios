import SwiftUI

struct ExperiencesList: View {

    @ObservedObject var viewModel: ExperiencesTab.ViewModel
    @Environment(\.editMode) var mode

    var body: some View {
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
    }
}

struct ExperiencesList_Previews: PreviewProvider {
    static var previews: some View {
        ExperiencesList(viewModel: ExperiencesTab.ViewModel(isPreview: true))
    }
}
