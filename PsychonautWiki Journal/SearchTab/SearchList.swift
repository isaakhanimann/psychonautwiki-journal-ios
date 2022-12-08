import SwiftUI

struct SearchList: View {

    @ObservedObject var searchViewModel: SearchViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                if !isSearching && searchViewModel.selectedCategories.isEmpty {
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
                Section {
                    ForEach(searchViewModel.filteredCustomSubstances) { cust in
                        NavigationLink {
                            EditCustomSubstanceView(customSubstance: cust)
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
            if isSearching && searchViewModel.filteredSubstances.isEmpty && searchViewModel.filteredCustomSubstances.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}
