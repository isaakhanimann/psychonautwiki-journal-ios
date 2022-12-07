import SwiftUI

struct SearchList: View {

    @ObservedObject var searchViewModel: SearchViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                if !isSearching {
                    let substancesWithColors = recentsViewModel.substancesWithColor
                    if !substancesWithColors.isEmpty {
                        Section("Recently Used") {
                            ForEach(substancesWithColors, id: \.substance.name) { substanceWithColor in
                                SearchSubstanceRow(
                                    substance: substanceWithColor.substance,
                                    color: substanceWithColor.color.swiftUIColor
                                )
                            }
                        }
                    }
                }
                if isSearching {
                    Section {
                        allSubstances
                    }
                } else {
                    Section("All Substances") {
                        allSubstances
                    }
                }
            }
            if isSearching && searchViewModel.filteredSubstances.isEmpty && searchViewModel.filteredCustomSubstances.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }

    var allSubstances: some View {
        Group {
            ForEach(searchViewModel.filteredCustomSubstances) { cust in
                NavigationLink {
                    CustomSubstanceView(customSubstance: cust)
                } label: {
                    VStack(alignment: .leading) {
                        Text(cust.nameUnwrapped).font(.headline)
                        Spacer().frame(height: 5)
                        Chip(name: "custom")
                    }
                }
            }
            ForEach(searchViewModel.filteredSubstances) { sub in
                SearchSubstanceRow(substance: sub, color: nil)
            }
        }
    }
}
