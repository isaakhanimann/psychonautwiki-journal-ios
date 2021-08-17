import SwiftUI

struct EditDangerousCategoryInteractionsView: View {

    @ObservedObject var substance: Substance

    var body: some View {
        List {
            ForEach(substance.category!.file!.categoriesUnwrappedSorted) { category in
                getRowContent(for: category)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func getRowContent(for fileCategory: Category) -> some View {
        let isSelected = substance.dangerousCategoryInteractionsUnwrapped.contains(fileCategory)
        return Button(action: {
            if isSelected {
                substance.removeFromDangerousCategoryInteractions(fileCategory)
            } else {
                substance.addToDangerousCategoryInteractions(fileCategory)
            }
        }, label: {
            HStack {
                Text(fileCategory.nameUnwrapped)
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
