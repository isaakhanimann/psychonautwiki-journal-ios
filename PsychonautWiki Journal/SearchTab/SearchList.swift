import SwiftUI

struct SearchList: View {

    @ObservedObject var searchViewModel: SearchViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var customsViewModel = CustomSubstancesViewModel()
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
                ForEach(customsViewModel.customSubstances) { cust in
                    NavigationLink {
                        CustomSubstanceView(customSubstance: cust)
                    } label: {
                        Text(cust.nameUnwrapped).font(.headline)
                    }
                }
                ForEach(searchViewModel.filteredSubstances) { sub in
                    SearchSubstanceRow(substance: sub, color: nil)
                }
            }
            if isSearching && searchViewModel.filteredSubstances.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}
