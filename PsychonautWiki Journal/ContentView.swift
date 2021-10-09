import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

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
                }
            }
        )
    }

    func maybeFetchAgain() {
        if shouldFetchAgain {
            if let file = storedFile.first {
                PsychonautWikiAPIController.fetchAndSaveNewSubstancesAndDeleteOldOnes(
                    oldFile: file
                )
            }
        }
    }

    var shouldFetchAgain: Bool {
        guard hasBeenSetupBefore else { return false }
        let oneWeek: TimeInterval = 60 * 60 * 24 * 7
        guard let file = storedFile.first else {return true}
        guard file.creationDateUnwrapped.distance(to: Date()) > oneWeek else {
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
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
