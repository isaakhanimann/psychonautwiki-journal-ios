import SwiftUI

struct SubstancePicker: View {

    let selectedSubstance: Substance?
    let substancesFile: SubstancesFile
    let chooseSubstanceAndMoveOn: (Substance) -> Void
    var goBackOnSelect = false

    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""

    var body: some View {
        let recentSubstancesFiltered = substancesFile.getRecentlyUsedSubstancesInOrder(
            maxSubstancesToGet: 5
        ).filter { substance in
            substance.nameUnwrapped.hasPrefix(searchText)
        }
        let favoritesFiltered = substancesFile.favoritesSorted.filter { substance in
            substance.nameUnwrapped.hasPrefix(searchText)
        }

        let categoriesFiltered = substancesFile.sortedCategoriesUnwrapped.filter { category in
            let filteredSubstancesInCategory = category.substancesUnwrapped.filter(doesSearchTermInclude)
            return !filteredSubstancesInCategory.isEmpty
        }
        Group {
            TextField("Search Substances", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
                .padding()
            List {
                if !recentSubstancesFiltered.isEmpty {
                    Section(header: Text("Recently Used")) {
                        ForEach(recentSubstancesFiltered) { substance in
                            SubstanceRow(substance: substance, chooseSubstanceAndMoveOn: chooseSubstanceAndMaybeGoBack)
                        }
                    }
                }
                if !favoritesFiltered.isEmpty {
                    Section(header: Text("Favorites")) {
                        ForEach(favoritesFiltered) { substance in
                            SubstanceRow(substance: substance, chooseSubstanceAndMoveOn: chooseSubstanceAndMaybeGoBack)
                        }
                    }
                }
                ForEach(categoriesFiltered) { category in
                    Section(header: Text(category.nameUnwrapped)) {
                        let filteredSubstances = category.sortedSubstancesUnwrapped.filter(doesSearchTermInclude)
                        ForEach(filteredSubstances) { substance in
                            SubstanceRow(substance: substance, chooseSubstanceAndMoveOn: chooseSubstanceAndMaybeGoBack)
                        }
                    }
                }

                if recentSubstancesFiltered.isEmpty
                    && favoritesFiltered.isEmpty
                    && categoriesFiltered.isEmpty {
                    Text("No substances match your search")
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
        }
    }

    private func doesSearchTermInclude(substance: Substance) -> Bool {
        if searchText.isEmpty {
            return true
        } else {
            return substance.nameUnwrapped.lowercased().contains(searchText.lowercased())
        }
    }

    private func chooseSubstanceAndMaybeGoBack(substance: Substance) {
        if goBackOnSelect {
            presentationMode.wrappedValue.dismiss()
        }
        chooseSubstanceAndMoveOn(substance)
    }

    private func isSelected(substance: Substance) -> Bool {
        substance == selectedSubstance
    }
}
