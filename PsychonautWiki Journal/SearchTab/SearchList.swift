import SwiftUI

struct SearchList: View {

    @ObservedObject var searchViewModel: SearchViewModel
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var customsViewModel = CustomSubstancesViewModel()
    @State private var isShowingAddCustomSubstance = false
    @Environment(\.isSearching) private var isSearching

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
                            isShowingAddCustomSubstance.toggle()
                        } label: {
                            Label("Add Custom", systemImage: "plus")
                        }
                    }.sheet(isPresented: $isShowingAddCustomSubstance) {
                        AddCustomSubstanceView()
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
