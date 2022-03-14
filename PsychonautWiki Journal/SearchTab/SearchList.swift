import SwiftUI

struct SearchList: View {

    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var presetViewModel = PresetViewModel()
    @Environment(\.isSearching) var isSearching

    var body: some View {
        ZStack {
            List {
                let showRecents = !isSearching && !recentsViewModel.recentSubstances.isEmpty
                if showRecents {
                    Section("Recently Used") {
                        ForEach(recentsViewModel.recentSubstances) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                SubstanceView(substance: sub)
                            }
                        }
                    }
                }
                ForEach(sectionedViewModel.sections) { sec in
                    Section(sec.sectionName) {
                        ForEach(sec.substances) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                SubstanceView(substance: sub)
                            }
                        }
                    }
                }
                Section(header: Text("Presets")) {
                    ForEach(presetViewModel.presets) { pre in
                        Text(pre.name ?? "hello")
                    }
                }
            }
            if isSearching && sectionedViewModel.sections.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SearchList_Previews: PreviewProvider {
    static var previews: some View {
        SearchList(
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true)
        )
    }
}
