import SwiftUI

struct SubstancePickerList: View {

    @Binding var pickedSubstance: Substance
    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    @Environment(\.isSearching) private var isSearching
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            List {
                ForEach(sectionedViewModel.sections) { sec in
                    Section(sec.sectionName) {
                        ForEach(sec.substances) { sub in
                            Button(sub.nameUnwrapped) {
                                pickedSubstance = sub
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
            if isSearching && sectionedViewModel.sections.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SubstancePickerList_Previews: PreviewProvider {
    static var previews: some View {
        SubstancePickerList(
            pickedSubstance: .constant(PreviewHelper.shared.substance),
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true)
        )
    }
}
