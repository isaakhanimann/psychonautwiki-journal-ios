import SwiftUI

struct SearchList: View {

    @ObservedObject var searchViewModel: SearchViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var customsViewModel = CustomSubstancesViewModel()
    @Environment(\.isSearching) private var isSearching
    @EnvironmentObject private var sheetViewModel: SheetViewModel

    var body: some View {
        ZStack {
            List {
                if !isSearching {
                    let substancesWithColors = recentsViewModel.substancesWithColor
                    if !substancesWithColors.isEmpty {
                        Section("Recently Used") {
                            ForEach(substancesWithColors, id: \.substance.name) { substanceWithColor in
                                NavigationLink {
                                    SubstanceView(substance: substanceWithColor.substance)
                                } label: {
                                    Image(systemName: "circle.fill")
                                        .font(.title2)
                                        .foregroundColor(substanceWithColor.color.swiftUIColor)
                                    Text(substanceWithColor.substance.name)
                                }
                            }
                        }
                    }
                    Section("Custom Substances") {
                        ForEach(customsViewModel.customSubstances) { cust in
                            NavigationLink(cust.nameUnwrapped) {
                                CustomSubstanceView(customSubstance: cust)
                            }
                        }
                        Button {
                            sheetViewModel.sheetToShow = .addCustom
                        } label: {
                            Label("Add Custom", systemImage: "plus")
                        }
                    }
                }
                ForEach(searchViewModel.filteredSubstances) { sub in
                    NavigationLink(sub.name) {
                        SubstanceView(substance: sub)
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
