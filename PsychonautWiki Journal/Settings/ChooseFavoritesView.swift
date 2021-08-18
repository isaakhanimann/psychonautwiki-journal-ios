import SwiftUI

struct ChooseFavoritesView: View {

    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        List {
            ForEach(file.sortedCategoriesUnwrapped) { category in
                if !category.substancesUnwrapped.isEmpty {
                    Section(header: Text(category.nameUnwrapped)) {
                        ForEach(category.sortedSubstancesUnwrapped) { substance in
                            FavoritesRowView(substance: substance)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Choose Favorites")
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
}
