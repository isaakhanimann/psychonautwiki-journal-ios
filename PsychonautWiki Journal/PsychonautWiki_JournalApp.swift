import SwiftUI

// swiftlint:disable type_name
@main
struct PsychonautWiki_JournalApp: App {

    @AppStorage(PersistenceController.hasInitialSubstancesKey) var hasInitialSubstances: Bool = false
    @AppStorage(PersistenceController.comesFromVersion10Key) var comesFromVersion10: Bool = false
    @StateObject var calendarWrapper = CalendarWrapper()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environmentObject(calendarWrapper)
                .accentColor(Color.blue)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                calendarWrapper.checkIfSomethingChanged()
                setupSubstances()
            }
        }
    }

    private func setupSubstances() {
        let needsCleanup = comesFromVersion10 && !hasInitialSubstances
        if needsCleanup {
            PersistenceController.shared.cleanupCoreData()
        } else if !hasInitialSubstances {
            PersistenceController.shared.addInitialSubstances()
        }
        hasInitialSubstances = true
    }
}
