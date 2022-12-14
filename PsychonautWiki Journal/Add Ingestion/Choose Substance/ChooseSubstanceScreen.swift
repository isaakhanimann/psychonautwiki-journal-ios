import SwiftUI

struct ChooseSubstanceScreen: View {
    @StateObject var searchViewModel = SearchViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ChooseSubstanceContent(
            searchText: $searchViewModel.searchText,
            filteredSuggestions: [],
            filteredSubstances: [],
            filteredCustomSubstances: [],
            dismiss: {dismiss()}
        )
    }
}

