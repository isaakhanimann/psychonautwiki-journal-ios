import SwiftUI

// swiftlint:disable type_name
@main
struct PsychonautWiki_JournalApp: App {

    let persistenceController = PersistenceController.shared
    @StateObject var connectivity = Connectivity()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(connectivity)
                .accentColor(Color.blue)
        }
    }
}
