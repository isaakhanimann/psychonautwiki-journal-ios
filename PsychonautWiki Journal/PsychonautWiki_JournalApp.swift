import SwiftUI

// swiftlint:disable type_name
@main
struct PsychonautWiki_JournalApp: App {

    let persistenceController = PersistenceController.shared
    @StateObject var calendarWrapper = CalendarWrapper()
    @StateObject var connectivity = Connectivity()

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(calendarWrapper)
                .environmentObject(connectivity)
                .accentColor(Color.blue)
                .onAppear {
                    SubstanceDecoder.isDefaultEnabled = isEyeOpen
                }
        }
    }
}
