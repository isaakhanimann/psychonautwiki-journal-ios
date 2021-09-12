import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false

    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @EnvironmentObject var connectivity: Connectivity
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    var body: some View {
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
            PsychonautWikiAPIController.fetchAndSaveNewSubstancesAndDeleteOldOnes(
                oldFile: storedFile.first!
            )
        }
    }

    var shouldFetchAgain: Bool {
        guard hasBeenSetupBefore else { return false }
        let oneDay: TimeInterval = 60 * 60 * 24 * 1
        guard storedFile.first!.creationDateUnwrapped.distance(to: Date()) > oneDay else {
            return false
        }
        return true
    }

    enum ActiveSheet: Identifiable {
        case setup, settings

        // swiftlint:disable identifier_name
        var id: Int {
            hashValue
        }
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
