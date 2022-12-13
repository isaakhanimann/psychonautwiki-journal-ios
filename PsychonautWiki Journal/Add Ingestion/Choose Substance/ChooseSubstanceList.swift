import SwiftUI

struct ChooseSubstanceList: View {

    @ObservedObject var searchViewModel: SearchViewModel
    let dismiss: () -> Void
    @StateObject var suggestionsViewModel = SuggestionsViewModel()
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ZStack {
            List {
                let suggestions = suggestionsViewModel.suggestions
                if !suggestions.isEmpty {
                    QuickLoggingSection(suggestions: suggestions)
                }
                Section("Other") {
                    ForEach(searchViewModel.filteredSubstances) { sub in
                        NavigationLink(sub.name) {
                            AcknowledgeInteractionsView(substance: sub, dismiss: dismiss)
                        }
                    }
                }
                Section("Custom") {
                    ForEach(searchViewModel.filteredCustomSubstances) { cust in
                        NavigationLink(cust.nameUnwrapped) {
                            CustomChooseRouteScreen(
                                substanceName: cust.nameUnwrapped,
                                units: cust.unitsUnwrapped,
                                dismiss: dismiss
                            )
                        }
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
