import SwiftUI

struct ChooseSubstanceView: View {

    @StateObject var viewModel = SearchTab.ViewModel()
    let dismiss: () -> Void
    let experience: Experience
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sections) { sec in
                    Section(sec.sectionName) {
                        ForEach(sec.substances) { sub in
                            SubstanceRow(substance: sub, dismiss: dismiss, experience: experience)
                        }
                    }
                }
                if isEyeOpen {
                    Section {
                        EmptyView()
                    } footer: {
                        Text(Constants.substancesDisclaimerIOS)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle("Add Ingestion")
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceView(
            dismiss: {},
            experience: PreviewHelper.shared.experiences.first!
        )
            .environmentObject(PreviewHelper.shared.experiences.first!)
    }
}
