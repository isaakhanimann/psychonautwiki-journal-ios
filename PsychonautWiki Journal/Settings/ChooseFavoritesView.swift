import SwiftUI

struct ChooseFavoritesView: View {

    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var connectivity: Connectivity

    var areThereAnyEnabledSubstances: Bool {
        !file.enabledSubstancesUnwrapped.isEmpty
    }

    var body: some View {
        Group {
            if areThereAnyEnabledSubstances {
                List(file.enabledSubstancesUnwrapped) { substance in
                    FavoritesRowView(substance: substance)
                }
                .listStyle(PlainListStyle())
            } else {
                Text("There are no enabled substances")
            }
        }
        .navigationTitle("Choose Favorites")
        .onDisappear {
            if moc.hasChanges {
                connectivity.sendFavoriteSubstances(from: file)
                try? moc.save()
            }
        }
    }
}

struct ChooseFavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseFavoritesView(file: helper.substancesFile)
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)

    }
}
