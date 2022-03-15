import SwiftUI

struct SearchList: View {

    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var presetsViewModel = PresetsViewModel()
    @Environment(\.isSearching) var isSearching
    @State private var isShowingAddPreset = false

    var body: some View {
        ZStack {
            List {
                if !isSearching {
                    if !recentsViewModel.recentSubstances.isEmpty {
                        Section("Recently Used") {
                            ForEach(recentsViewModel.recentSubstances) { sub in
                                NavigationLink(sub.nameUnwrapped) {
                                    SubstanceView(substance: sub)
                                }
                            }
                        }
                    }
                    Section(header: Text("Presets")) {
                        ForEach(presetsViewModel.presets) { pre in
                            NavigationLink(pre.nameUnwrapped) {
                                PresetView(preset: pre)
                            }
                        }
                        Button {
                            isShowingAddPreset.toggle()
                        } label: {
                            Label("Add Preset", systemImage: "plus")
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
            }
            if isSearching && sectionedViewModel.sections.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $isShowingAddPreset) {
            AddPresetView()
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
