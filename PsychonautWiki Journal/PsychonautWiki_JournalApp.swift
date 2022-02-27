import SwiftUI

// swiftlint:disable type_name
@main
struct PsychonautWiki_JournalApp: App {

    @AppStorage(PersistenceController.hasCleanedUpCoreDataKey) var hasCleanedUpCoreData: Bool = false
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
                if !hasCleanedUpCoreData {
                    PersistenceController.shared.cleanupCoreData()
                    hasCleanedUpCoreData = true
                }
            }
        }
    }
}
