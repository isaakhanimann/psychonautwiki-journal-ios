import SwiftUI

@main
struct PsychonautWiki_JournalApp: App {

    @StateObject private var toastViewModel = ToastViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationViewStyle(.stack)
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                .environmentObject(toastViewModel)
                .accentColor(Color.blue)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                PersistenceController.shared.saveViewContext()
            }
        }
    }

}
