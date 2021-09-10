import SwiftUI

struct ChooseFavoritesView: View {

    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc

    var areThereAnyEnabledSubstances: Bool {
        !file.allEnabledSubstancesUnwrapped.isEmpty
    }

    var body: some View {
        Group {
            if areThereAnyEnabledSubstances {
                List {
                    ForEach(file.sortedCategoriesUnwrapped) { category in
                        if !category.sortedEnabledSubstancesUnwrapped.isEmpty {
                            Section(header: Text(category.nameUnwrapped)) {
                                ForEach(category.sortedEnabledSubstancesUnwrapped) { substance in
                                    FavoritesRowView(substance: substance)
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                Text("There are no enabled substances")
            }
        }
        .navigationTitle("Choose Favorites")
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
}

struct ChooseFavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseFavoritesView(file: helper.substancesFile)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

    }
}
