import SwiftUI

struct ChooseSubstanceScreen: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ChooseSubstanceContent(
            searchText: $viewModel.searchText,
            filteredSuggestions: viewModel.filteredSuggestions,
            filteredSubstances: viewModel.filteredSubstances,
            filteredCustomSubstances: viewModel.filteredCustomSubstances,
            dismiss: {dismiss()}
        )
    }
}

