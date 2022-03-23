import SwiftUI

struct ChooseSubstanceList: View {

    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var presetsViewModel = PresetsViewModel()
    @StateObject var customsViewModel = CustomSubstancesViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                if !isSearching {
                    if !recentsViewModel.recentSubstances.isEmpty {
                        Section("Recently Used") {
                            ForEach(recentsViewModel.recentSubstances) { sub in
                                NavigationLink(sub.nameUnwrapped) {
                                    if sub.hasAnyInteractions && isEyeOpen {
                                        AcknowledgeInteractionsView(substance: sub)
                                    } else {
                                        ChooseRouteView(substance: sub)
                                    }
                                }
                            }
                        }
                    }
                    if !presetsViewModel.presets.isEmpty {
                        Section("Presets") {
                            ForEach(presetsViewModel.presets) { pre in
                                let hasInteractions = pre.substances.contains(where: { sub in
                                    sub.hasAnyInteractions
                                }) || !pre.dangerousInteractions.isEmpty
                                || !pre.unsafeInteractions.isEmpty
                                || !pre.uncertainInteractions.isEmpty
                                if hasInteractions && isEyeOpen {
                                    NavigationLink(pre.nameUnwrapped) {
                                        PresetAcknowledgeInteractionsView(preset: pre)
                                    }
                                } else {
                                    NavigationLink(pre.nameUnwrapped) {
                                        PresetChooseDoseView(preset: pre)
                                    }
                                }

                            }
                        }
                    }
                    if !customsViewModel.customSubstances.isEmpty {
                        Section("Custom Substances") {
                            ForEach(customsViewModel.customSubstances) { cust in
                                NavigationLink(cust.nameUnwrapped) {
                                    AddCustomIngestionView(customSubstance: cust)
                                }
                            }
                        }
                    }
                }
                ForEach(sectionedViewModel.sections) { sec in
                    Section(sec.sectionName) {
                        ForEach(sec.substances) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                if sub.hasAnyInteractions && isEyeOpen {
                                    AcknowledgeInteractionsView(substance: sub)
                                } else {
                                    ChooseRouteView(substance: sub)
                                }
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
    }
}

struct ChooseSubstanceList_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceList(
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true)
        )
    }
}
