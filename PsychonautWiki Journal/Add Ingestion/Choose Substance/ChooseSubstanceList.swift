import SwiftUI

struct ChooseSubstanceList: View {

    @ObservedObject var searchViewModel: SearchViewModel
    let dismiss: DismissAction
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var customsViewModel = CustomSubstancesViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                if !isSearching {
                    let substancesWithColors = recentsViewModel.substancesWithColor
                    if !substancesWithColors.isEmpty {
                        Section("Recently Used") {
                            ForEach(substancesWithColors) { substanceWithColor in
                                NavigationLink(substanceWithColor.substance.name) {
                                    AcknowledgeInteractionsView(substance: substanceWithColor.substance, dismiss: dismiss)
                                }
                            }
                        }
                    }
                    if !customsViewModel.customSubstances.isEmpty {
                        Section("Custom Substances") {
                            ForEach(customsViewModel.customSubstances) { cust in
                                NavigationLink(cust.nameUnwrapped) {
                                    AddCustomIngestionView(customSubstance: cust, dismiss: dismiss)
                                }
                            }
                        }
                    }
                }
                ForEach(searchViewModel.filteredSubstances) { sub in
                    NavigationLink(sub.name) {
                        AcknowledgeInteractionsView(substance: sub, dismiss: dismiss)
                    }
                }
            }
            if isSearching && searchViewModel.filteredSubstances.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}
