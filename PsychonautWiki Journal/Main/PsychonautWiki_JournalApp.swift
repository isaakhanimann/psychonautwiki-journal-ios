import SwiftUI

// swiftlint:disable type_name
@main
struct PsychonautWiki_JournalApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // swiftlint:disable line_length
    @AppStorage(PersistenceController.hasInitialSubstancesOfCurrentVersion) var hasInitialSubstancesOfCurrentVersion: Bool = false
    @AppStorage(PersistenceController.comesFromVersion10Key) var comesFromVersion10: Bool = false
    @StateObject private var calendarWrapper = CalendarWrapper()
    @StateObject private var sheetViewModel = SheetViewModel()
    @StateObject private var toastViewModel = ToastViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationViewStyle(.stack)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environmentObject(calendarWrapper)
                .environmentObject(sheetViewModel)
                .environmentObject(toastViewModel)
                .accentColor(Color.blue)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                appHasBecomeActive()
            } else if phase == .background {
                PersistenceController.shared.saveViewContext()
                appDelegate.scheduleSubstancesRefresh()
            }
        }
    }

    private func appHasBecomeActive() {
        calendarWrapper.checkIfSomethingChanged()
        if !hasInitialSubstancesOfCurrentVersion {
            migrateOrSetup()
        }
    }

    private func migrateOrSetup() {
        let needsCleanup = comesFromVersion10
        if needsCleanup {
            PersistenceController.shared.cleanupCoreData()
        } else {
            PersistenceController.shared.addInitialSubstances()
        }
        hasInitialSubstancesOfCurrentVersion = true
    }
}
