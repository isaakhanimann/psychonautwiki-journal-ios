import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false
    @Environment(\.scenePhase) var scenePhase

    @FetchRequest(
        entity: Experience.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
    ) var experiences: FetchedResults<Experience>
    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

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
            } else {
                WatchFaceView(ingestions: [])
                    .tag(2)
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
        .onChange(
            of: scenePhase,
            perform: { newPhase in
                if newPhase == .active {
                    if shouldFetchAgain {
                        PsychonautWikiAPIController.fetchAndSaveNewSubstancesAndDeleteOldOnes(
                            oldFile: storedFile.first!
                        )
                    }
                }
            }
        )
    }

    var shouldFetchAgain: Bool {
        guard !hasBeenSetupBefore else { return false }
        let oneDay: TimeInterval = 60 * 60 * 24 * 1
        guard storedFile.first!.creationDateUnwrapped.distance(to: Date()) > oneDay else {
            return false
        }
        return true
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
