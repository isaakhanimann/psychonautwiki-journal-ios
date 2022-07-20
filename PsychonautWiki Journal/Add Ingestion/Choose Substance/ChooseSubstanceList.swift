import SwiftUI

struct ChooseSubstanceList: View {

    @ObservedObject var searchViewModel: SearchViewModel
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
                                    SubstanceView(substance: substanceWithColor.substance)
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
                ForEach(searchViewModel.filteredSubstances) { sub in
                    Text(sub.name)
                }
            }
            if isSearching && searchViewModel.filteredSubstances.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}
