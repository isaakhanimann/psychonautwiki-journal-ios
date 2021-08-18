import SwiftUI

struct SettingsView: View {

    let toggleSettingsVisibility: () -> Void

    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: ChooseInteractionsView(file: storedFile.first!),
                    label: {
                        Label("Choose Interactions", systemImage: "bolt.horizontal.fill")
                    }
                )

                NavigationLink(
                    destination: ChooseFavoritesView(file: storedFile.first!),
                    label: {
                        Label("Choose Favorites", systemImage: "star.fill")
                    }
                )

                CalendarSection()

            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings"))
            .navigationBarItems(
                trailing: Button("Done", action: toggleSettingsVisibility)
            )
            .onDisappear(perform: {
                if moc.hasChanges {
                    try? moc.save()
                }
            })
        }
        .currentDeviceNavigationViewStyle()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(toggleSettingsVisibility: {})
    }
}
