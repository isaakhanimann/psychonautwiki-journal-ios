import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    @EnvironmentObject var connectivity: Connectivity
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: Experience.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
    ) var experiences: FetchedResults<Experience>

    @State private var selection = 2

    var body: some View {
        TabView(selection: $selection) {
            SettingsTab()
                .tag(1)
            Group {
                if let activeExperienceUnwrapped = activeExperience {
                    WatchFaceView(ingestions: activeExperienceUnwrapped.sortedIngestionsUnwrapped)
                } else {
                    Button(action: createExperience) {
                        Label("Start Experience", systemImage: "plus")
                    }
                }
            }
            .tag(2)
            Group {
                if let activeExperienceUnwrapped = activeExperience {
                    IngestionsTab(experience: activeExperienceUnwrapped)
                } else {
                    Text("No experience started yet")
                }
            }
            .tag(3)
        }
        .fullScreenCover(
            isPresented: Binding<Bool>(
                get: {!hasBeenSetupBefore},
                set: {newValue in hasBeenSetupBefore = !newValue}
            ),
            content: {
                WatchWelcome()
            }
        )
    }

    private func createExperience() {
        withAnimation {
            let experience = Experience(context: moc)
            let now = Date()
            experience.creationDate = now
            experience.title = now.asDateString
            let data = ["text": "Experience created at \(now.asTimeString)"]
            connectivity.transferUserInfo(data)
            try? moc.save()
            selection = 3
        }
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
    }
}
