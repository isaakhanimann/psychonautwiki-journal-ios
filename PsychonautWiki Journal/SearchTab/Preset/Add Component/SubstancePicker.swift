import SwiftUI

struct SubstancePicker: View {

    @Binding var pickedSubstance: Substance
    @StateObject private var sectionedViewModel = SectionedSubstancesViewModel()

    var body: some View {
        SubstancePickerList(
            pickedSubstance: $pickedSubstance,
            sectionedViewModel: sectionedViewModel
        )
        .searchable(text: $sectionedViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .disableAutocorrection(true)
    }
}

struct SubstancePicker_Previews: PreviewProvider {
    static var previews: some View {
        SubstancePicker(pickedSubstance: .constant(PreviewHelper.shared.substance))
    }
}
