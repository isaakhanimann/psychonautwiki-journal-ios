import SwiftUI

@main
struct PsychonautWiki_JournalApp: App {

    @StateObject private var toastViewModel = ToastViewModel()
    @StateObject private var authenticator = Authenticator()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            if authenticator.isUnlocked {
                ContentView()
                    .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                    .environmentObject(toastViewModel)
                    .environmentObject(authenticator)
                    .accentColor(Color.blue)
            } else {
                LockScreen(isFaceIDEnabled: authenticator.isFaceIDEnabled)
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive {
                print("Inactive")
            } else if phase == .active {
                print("Active")
            } else if phase == .background {
                print("Background")
            }
            authenticator.onChange(of: phase)
        }
    }
}
