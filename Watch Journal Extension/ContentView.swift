import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    @FetchRequest(
        entity: Experience.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
    ) var experiences: FetchedResults<Experience>

    @Environment(\.managedObjectContext) var moc

    @State private var selection = 2

    var body: some View {
        TabView(selection: $selection) {
            SettingsTab()
                .tag(1)
            if let firstExperience = experiences.first {
                WatchFaceIngestionObserverView(experience: firstExperience)
                    .tag(2)
                IngestionsTab(experience: firstExperience)
                    .tag(3)
            }
        }
        .fullScreenCover(
            isPresented: Binding<Bool>(
                get: {!hasBeenSetupBefore},
                set: {newValue in hasBeenSetupBefore = !newValue}
            ),
            content: {
                WatchWelcome()
                    .environment(\.managedObjectContext, moc)
                    .accentColor(Color.blue)
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(Connectivity())
            .accentColor(Color.blue)
    }
}
