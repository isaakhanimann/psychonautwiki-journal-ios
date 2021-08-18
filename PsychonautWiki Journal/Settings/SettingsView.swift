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
                Section(header: Text("Substances and Interactions")) {

                    VStack(spacing: 10) {
                        Text("Last Fetch: \(storedFile.first!.creationDateUnwrapped.asDateAndTime)")
                        Button(action: fetchSubstances, label: {
                            Label("Fetch Now", systemImage: "arrow.clockwise")
                        })
                    }

                    NavigationLink(
                        destination: ChooseInteractionsView(file: storedFile.first!),
                        label: {
                            Label("Choose Interactions", systemImage: "burst.fill")
                        }
                    )

                    NavigationLink(
                        destination: ChooseFavoritesView(file: storedFile.first!),
                        label: {
                            Label("Choose Favorites", systemImage: "star.fill")
                        }
                    )
                }

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

    private func fetchSubstances() {

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(toggleSettingsVisibility: {})
    }
}
