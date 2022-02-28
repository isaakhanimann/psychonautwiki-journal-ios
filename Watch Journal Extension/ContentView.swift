import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasSeenWelcomeKey) var hasSeenWelcome: Bool = false

    @FetchRequest(
        entity: Experience.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
    ) var experiences: FetchedResults<Experience>

    @State private var selection = 2

    var body: some View {
        Group {
            if hasSeenWelcome {
                TabView(selection: $selection) {
                    SettingsTab()
                        .tag(1)
                    if let firstExperience = experiences.first {
                        IngestionObserverView(experience: firstExperience)
                            .tag(2)
                        IngestionsTab(experience: firstExperience)
                            .tag(3)
                    } else {
                        WatchFaceView(
                            ingestions: [],
                            clockHandStyle: .hourAndMinute,
                            timeStyle: .currentTime
                        )
                        .tag(2)
                    }
                }
            } else {
                WatchWelcome()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .accentColor(Color.blue)
    }
}
