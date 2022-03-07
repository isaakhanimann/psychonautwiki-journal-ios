import SwiftUI

struct SearchList<Content: View>: View {

    public init(
        sectionedViewModel: SectionedSubstancesViewModel,
        recentsViewModel: RecentSubstancesViewModel,
        @ViewBuilder getRowForSubstance: @escaping (Substance) -> Content
    ) {
        self.getRowForSubstance = getRowForSubstance
        self.sectionedViewModel = sectionedViewModel
        self.recentsViewModel = recentsViewModel
    }

    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    @ObservedObject var recentsViewModel: RecentSubstancesViewModel
    let getRowForSubstance: (Substance) -> Content
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @Environment(\.isSearching) var isSearching

    var body: some View {
        List {
            let showRecents = !isSearching && !recentsViewModel.recentSubstances.isEmpty
            if showRecents {
                Section("Recently Used") {
                    ForEach(recentsViewModel.recentSubstances) { sub in
                        getRowForSubstance(sub)
                    }
                }
            }
            ForEach(sectionedViewModel.sections) { sec in
                Section(sec.sectionName) {
                    ForEach(sec.substances) { sub in
                        getRowForSubstance(sub)
                    }
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
    }

    let substancesDisclaimer =
"""
This list is neither a suggestion nor an incitement to the consumption of these substances.
Using these substances always involves risks and can never be considered safe.

Consult a doctor before making medical decisions.
"""
}

struct SearchList_Previews: PreviewProvider {
    static var previews: some View {
        SearchList(
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true),
            recentsViewModel: RecentSubstancesViewModel(isPreview: true)
        ) { sub in
            NavigationLink(sub.nameUnwrapped) {
                SubstanceView(substance: sub)
            }

        }
    }
}
