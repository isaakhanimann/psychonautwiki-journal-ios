import SwiftUI

struct EditUnsafeGeneralInteractionsView: View {

    @ObservedObject var substance: Substance

    var body: some View {
        List {
            ForEach(substance.category!.file!.generalInteractionsUnwrappedSorted) { interaction in
                getRowContent(for: interaction)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func getRowContent(for fileInteraction: GeneralInteraction) -> some View {
        let isSelected = substance.unsafeGeneralInteractionsUnwrapped.contains(fileInteraction)
        return Button(action: {
            if isSelected {
                substance.removeFromUnsafeGeneralInteractions(fileInteraction)
            } else {
                substance.addToUnsafeGeneralInteractions(fileInteraction)
            }
        }, label: {
            HStack {
                Text(fileInteraction.nameUnwrapped)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
        })
    }
}
