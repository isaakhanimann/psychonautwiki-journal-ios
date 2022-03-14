import SwiftUI

struct ChooseSubstanceList: View {

    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    let experience: Experience
    let dismiss: (AddResult) -> Void
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var presetViewModel = PresetViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @Environment(\.isSearching) var isSearching

    var body: some View {
        ZStack {
            List {
                let showRecents = !isSearching && !recentsViewModel.recentSubstances.isEmpty
                if showRecents {
                    Section("Recently Used") {
                        ForEach(recentsViewModel.recentSubstances) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                if sub.hasAnyInteractions {
                                    AcknowledgeInteractionsView(
                                        substance: sub,
                                        dismiss: dismiss,
                                        experience: experience
                                    )
                                } else {
                                    ChooseRouteView(
                                        substance: sub,
                                        dismiss: dismiss,
                                        experience: experience
                                    )
                                }
                            }
                        }
                    }
                }
                ForEach(sectionedViewModel.sections) { sec in
                    Section(sec.sectionName) {
                        ForEach(sec.substances) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                if sub.hasAnyInteractions {
                                    AcknowledgeInteractionsView(
                                        substance: sub,
                                        dismiss: dismiss,
                                        experience: experience
                                    )
                                } else {
                                    ChooseRouteView(
                                        substance: sub,
                                        dismiss: dismiss,
                                        experience: experience
                                    )
                                }
                            }
                        }
                    }
                }
                Section(header: Text("Presets")) {
                    ForEach(presetViewModel.presets) { pre in
                        Text(pre.name ?? "hello")
                    }
                }
                if isEyeOpen {
                    Section {
                        EmptyView()
                    } footer: {
                        Text(substancesDisclaimer)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            if isSearching && sectionedViewModel.sections.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }

    let substancesDisclaimer =
"""
This list is neither a suggestion nor an incitement to the consumption of these substances.
Using these substances always involves risks and can never be considered safe.

Consult a doctor before making medical decisions.
"""
}

struct ChooseSubstanceList_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceList(
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true),
            experience: PreviewHelper.shared.experiences.first!,
            dismiss: {_ in }
        )
    }
}
