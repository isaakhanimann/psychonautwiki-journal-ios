import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false
    @AppStorage(PersistenceController.hasCleanedUpCoreDataKey) var hasCleanedUpCoreData: Bool = false

    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @EnvironmentObject var connectivity: Connectivity
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var storedFile: FetchedResults<SubstancesFile>

    var body: some View {
        ZStack {
            HandleUniversalURLView()
            Group {
                if hasBeenSetupBefore {
                    HomeView()
                        .onAppear(perform: maybeFetchAgain)
                } else {
                    WelcomeScreen()
                        .environment(\.managedObjectContext, self.moc)
                        .environmentObject(calendarWrapper)
                        .accentColor(Color.blue)
                }
            }
        }
        .onChange(
            of: scenePhase,
            perform: { newPhase in
                if newPhase == .active {
                    calendarWrapper.checkIfSomethingChanged()
                    maybeFetchAgain()
                    if !hasCleanedUpCoreData {
                        PersistenceController.shared.cleanupCoreData()
                        hasCleanedUpCoreData = true
                    }
                }
            }
        )
    }

    func maybeFetchAgain() {
        if shouldFetchAgain {
            performPsychonautWikiAPIRequest { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let data):
                    try? PersistenceController.shared.decodeAndSaveFile(from: data)
                }
            }
        }
    }

    var shouldFetchAgain: Bool {
        guard hasBeenSetupBefore else { return false }
        let twoWeeks: TimeInterval = 60 * 60 * 24 * 14
        guard let file = storedFile.first else {return true}
        guard file.creationDateUnwrapped.distance(to: Date()) > twoWeeks else {
            return false
        }
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .environmentObject(Connectivity())
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
