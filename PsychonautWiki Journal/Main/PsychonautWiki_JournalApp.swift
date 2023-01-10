import SwiftUI
import LocalAuthentication

@main
struct PsychonautWiki_JournalApp: App {

    @StateObject private var toastViewModel = ToastViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(PersistenceController.hasToUnlockAppKey) var hasToUnlockApp: Bool = false
    @State private var isUnlocked = false

    var body: some Scene {
        WindowGroup {
            if isUnlocked {
                ContentView()
                    .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
                    .environmentObject(toastViewModel)
                    .accentColor(Color.blue)
            } else {
                LockScreen()
            }
        }
        .onChange(of: scenePhase) { phase in
            if hasToUnlockApp {
                if phase == .background || phase == .inactive {
                    isUnlocked = false
                } else if phase == .active && !isUnlocked {
                    authenticate()
                }
            } else {
                isUnlocked = true
            }
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate yourself to see your journal."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    Task { @MainActor in
                        isUnlocked = true
                    }
                } else {
                    // error
                }
            }
        } else {
            // no biometrics
        }
    }
}
