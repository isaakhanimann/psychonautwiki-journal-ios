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
            WatchFaceView(ingestions: experiences.first?.sortedIngestionsUnwrapped ?? [])
                .tag(2)
            if let firstExperience = experiences.first {
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

    var activeExperience: Experience? {
        guard !experiences.isEmpty else {
            return nil
        }
        let activeExperiences = experiences.filter { experience in
            experience.isActive && !experience.sortedIngestionsUnwrapped.isEmpty
        }

        let sortedExperiences = activeExperiences.sorted { experience1, experience2 in
            experience1.sortedIngestionsUnwrapped.first!.timeUnwrapped
                <
                experience2.sortedIngestionsUnwrapped.first!.timeUnwrapped
        }
        if let latestExperience = sortedExperiences.first {
            return latestExperience
        }

        if experiences.first!.creationDateUnwrapped.distance(to: Date()) < 60 * 60 * 5 {
            return experiences.first!
        } else {
            return nil
        }
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
