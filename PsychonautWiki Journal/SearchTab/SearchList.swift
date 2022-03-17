import SwiftUI

struct SearchList: View {

    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var presetsViewModel = PresetsViewModel()
    @StateObject var customsViewModel = CustomSubstancesViewModel()
    @Environment(\.isSearching) var isSearching
    @State private var sheetToShow: Sheet?

    enum Sheet: Identifiable {
        // swiftlint:disable identifier_name
        var id: Sheet {
            self
        }
        case addPreset, addCustomSubstance
    }

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
                    Section("Presets") {
                        ForEach(presetsViewModel.presets) { pre in
                            NavigationLink(pre.nameUnwrapped) {
                                PresetView(preset: pre)
                            }
                        }
                        Button {
                            sheetToShow = .addPreset
                        } label: {
                            Label("Add Preset", systemImage: "plus")
                        }
                    }
                    Section("Custom Substances") {
                        ForEach(customsViewModel.customSubstances) { cust in
                            NavigationLink(cust.nameUnwrapped) {
                                CustomSubstanceView(customSubstance: cust)
                            }
                        }
                        Button {
                            sheetToShow = .addCustomSubstance
                        } label: {
                            Label("Add Custom", systemImage: "plus")
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
        .sheet(item: $sheetToShow, content: { item in
            switch item {
            case .addPreset:
                AddPresetView()
            case .addCustomSubstance:
                AddCustomSubstanceView()
            }
        })
    }
}

struct SearchList_Previews: PreviewProvider {
    static var previews: some View {
        SearchList(
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true)
        )
    }
}
