import SwiftUI

struct ChooseSubstanceView: View {

    @StateObject var sectionedViewModel = SectionedSubstancesViewModel()
    let dismiss: (AddResult) -> Void
    let experience: Experience

    var body: some View {
        NavigationView {
            ChooseSubstanceList(
                sectionedViewModel: sectionedViewModel,
                experience: experience,
                dismiss: dismiss
            )
            .navigationBarTitle("Add Ingestion")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss(.cancelled)
                    }
                }
            }
        }
        .searchable(text: $sectionedViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceView(
            dismiss: {print($0)},
            experience: PreviewHelper.shared.experiences.first!
        )
    }
}
